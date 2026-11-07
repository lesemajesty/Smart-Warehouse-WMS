package com.warehouse.service;

import com.warehouse.entity.OperationLog;
import com.warehouse.entity.User;
import com.warehouse.repository.OperationLogRepository;
import com.warehouse.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class OperationLogService {

    private final OperationLogRepository logRepository;
    private final UserRepository userRepository;

    public OperationLogService(OperationLogRepository logRepository, UserRepository userRepository) {
        this.logRepository = logRepository;
        this.userRepository = userRepository;
    }

    public void log(String action, String targetType, Long targetId, String detail) {
        log(action, targetType, targetId, detail, null);
    }

    /**
     * 写审计日志。任何异常都不能影响主业务，因此整体 try/catch。
     */
    public void log(String action, String targetType, Long targetId, String detail, String warehouse) {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            String username = (auth != null && auth.isAuthenticated()
                    && !"anonymousUser".equals(auth.getName())) ? auth.getName() : "system";
            User user = userRepository.findByUsername(username).orElse(null);

            OperationLog log = new OperationLog();
            log.setUsername(username);
            log.setRole(user == null ? null : user.getRole());
            log.setAction(action);
            log.setTargetType(targetType);
            log.setTargetId(targetId);
            log.setDetail(truncate(detail));
            log.setWarehouse(warehouse != null ? warehouse : (user == null ? null : user.getWarehouse()));
            log.setIp(currentIp());
            log.setCreateTime(LocalDateTime.now());
            logRepository.save(log);
        } catch (Exception ignored) {
            // 审计失败不阻断业务
        }
    }

    public List<OperationLog> latest() {
        return logRepository.findTop200ByOrderByCreateTimeDesc();
    }

    private String truncate(String value) {
        if (value == null) return null;
        return value.length() <= 500 ? value : value.substring(0, 500);
    }

    private String currentIp() {
        try {
            ServletRequestAttributes attributes =
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) return null;
            HttpServletRequest request = attributes.getRequest();
            String forwarded = request.getHeader("X-Forwarded-For");
            if (forwarded != null && !forwarded.isBlank()) {
                return forwarded.split(",")[0].trim();
            }
            return request.getRemoteAddr();
        } catch (Exception e) {
            return null;
        }
    }
}
