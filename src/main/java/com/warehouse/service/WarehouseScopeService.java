package com.warehouse.service;

import com.warehouse.entity.User;
import com.warehouse.exception.WarehouseAccessException;
import com.warehouse.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

/**
 * 仓库范围：
 * - ADMIN：不限仓库（null）
 * - WAREHOUSE：只能操作自己绑定的仓库
 * - VIEWER：只读，可查看全部
 * - 仓库员未绑定仓库：不能操作，列表也查不到数据
 */
@Service
public class WarehouseScopeService {

    private final UserRepository userRepository;

    public WarehouseScopeService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * 列表可见范围：null 表示全部；空串表示未绑定、无可见数据；否则为绑定仓库。
     */
    public String scope(Authentication authentication) {
        if (authentication == null) {
            return "";
        }
        if (hasRole(authentication, "ROLE_ADMIN") || hasRole(authentication, "ROLE_VIEWER")) {
            return null;
        }
        if (!hasRole(authentication, "ROLE_WAREHOUSE")) {
            return "";
        }
        User user = userRepository.findByUsername(authentication.getName()).orElse(null);
        if (user == null || user.getWarehouse() == null || user.getWarehouse().isBlank()) {
            return "";
        }
        return user.getWarehouse().trim();
    }

    /**
     * 可写范围：管理员返回 null（不限）；仓库员返回绑定仓库；未绑定直接 403。
     */
    public String requireOperable(Authentication authentication) {
        if (authentication == null) {
            throw new WarehouseAccessException("未登录");
        }
        if (hasRole(authentication, "ROLE_ADMIN")) {
            return null;
        }
        if (!hasRole(authentication, "ROLE_WAREHOUSE")) {
            throw new WarehouseAccessException("当前角色不能执行出入库操作");
        }
        User user = userRepository.findByUsername(authentication.getName()).orElse(null);
        if (user == null || user.getWarehouse() == null || user.getWarehouse().isBlank()) {
            throw new WarehouseAccessException("当前账号尚未绑定仓库，请联系管理员");
        }
        return user.getWarehouse().trim();
    }

    private boolean hasRole(Authentication authentication, String role) {
        return authentication.getAuthorities().stream()
                .anyMatch(a -> role.equals(a.getAuthority()));
    }
}
