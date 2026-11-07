package com.warehouse.controller;

import com.warehouse.entity.User;
import com.warehouse.exception.BusinessException;
import com.warehouse.repository.UserRepository;
import com.warehouse.service.OperationLogService;
import com.warehouse.service.PasswordService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@PreAuthorize("hasRole('ADMIN')")
public class UserController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final PasswordService passwordService;
    private final OperationLogService operationLogService;

    public UserController(UserRepository userRepository, PasswordEncoder passwordEncoder,
                          PasswordService passwordService, OperationLogService operationLogService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.passwordService = passwordService;
        this.operationLogService = operationLogService;
    }

    /** 不返回密码字段 */
    @GetMapping
    public List<Map<String, Object>> getAll() {
        return userRepository.findAll().stream().map(UserController::toView).toList();
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> create(@RequestBody User request) {
        String username = request.getUsername() == null ? "" : request.getUsername().trim();
        if (username.isEmpty()) {
            throw new BusinessException("用户名不能为空");
        }
        if (userRepository.existsByUsername(username)) {
            throw new BusinessException("用户名已存在");
        }

        User user = new User();
        user.setUsername(username);
        String role = request.getRole() == null || request.getRole().isBlank() ? "WAREHOUSE" : request.getRole();
        if (!List.of("ADMIN", "WAREHOUSE", "VIEWER").contains(role)) {
            throw new BusinessException("无效的角色");
        }
        user.setRole(role);

        String warehouse = normalizeWarehouse(request.getWarehouse());
        if ("ADMIN".equals(role) || "VIEWER".equals(role)) {
            warehouse = null;
        }
        if ("WAREHOUSE".equals(role) && warehouse == null) {
            throw new BusinessException("仓库员必须绑定仓库");
        }
        user.setWarehouse(warehouse);

        String rawPassword = request.getPassword() == null || request.getPassword().isBlank()
                ? "123456"
                : request.getPassword();
        user.setPassword(passwordEncoder.encode(rawPassword));
        user.setCreateTime(LocalDateTime.now());
        userRepository.save(user);
        operationLogService.log("新增用户", "user", user.getId(),
                "用户名 " + username + "，角色 " + user.getRole() + "，仓库 "
                        + (user.getWarehouse() == null ? "不限" : user.getWarehouse()));

        return ResponseEntity.ok(toView(user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        String username = userRepository.findById(id).map(User::getUsername).orElse("ID " + id);
        userRepository.deleteById(id);
        operationLogService.log("删除用户", "user", id, "用户名 " + username);
        return ResponseEntity.ok().build();
    }

    /** 管理员给仓库员绑定/调整仓库（一名员工只能绑定一个仓库） */
    @PutMapping("/{id}/warehouse")
    public ResponseEntity<Map<String, Object>> bindWarehouse(@PathVariable Long id,
                                                             @RequestBody Map<String, String> body) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BusinessException("用户不存在"));
        if (!"WAREHOUSE".equals(user.getRole())) {
            throw new BusinessException("只有仓库员需要绑定仓库");
        }
        String warehouse = normalizeWarehouse(body.get("warehouse"));
        if (warehouse == null) {
            throw new BusinessException("仓库不能为空");
        }
        user.setWarehouse(warehouse);
        userRepository.save(user);
        operationLogService.log("绑定仓库", "user", user.getId(),
                "用户 " + user.getUsername() + " 绑定 " + warehouse);
        return ResponseEntity.ok(toView(user));
    }

    /** 管理员重置指定用户的密码（无需原密码） */
    @PostMapping("/{id}/password")
    public ResponseEntity<Void> resetPassword(@PathVariable Long id,
                                              @RequestBody Map<String, String> body) {
        passwordService.resetPassword(id, body.get("newPassword"));
        operationLogService.log("重置密码", "user", id, "重置用户 ID " + id + " 的密码");
        return ResponseEntity.ok().build();
    }

    private static String normalizeWarehouse(String warehouse) {
        if (warehouse == null || warehouse.isBlank()) {
            return null;
        }
        return warehouse.trim();
    }

    private static Map<String, Object> toView(User user) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("role", user.getRole());
        data.put("warehouse", user.getWarehouse());
        data.put("createTime", user.getCreateTime());
        return data;
    }
}
