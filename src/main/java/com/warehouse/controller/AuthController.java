package com.warehouse.controller;

import com.warehouse.entity.User;
import com.warehouse.exception.BusinessException;
import com.warehouse.repository.UserRepository;
import com.warehouse.service.PasswordService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final SecurityContextRepository securityContextRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final PasswordService passwordService;
    private final com.warehouse.service.OperationLogService operationLogService;

    public AuthController(AuthenticationManager authenticationManager,
                          SecurityContextRepository securityContextRepository,
                          UserRepository userRepository,
                          PasswordEncoder passwordEncoder,
                          PasswordService passwordService,
                          com.warehouse.service.OperationLogService operationLogService) {
        this.authenticationManager = authenticationManager;
        this.securityContextRepository = securityContextRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.passwordService = passwordService;
        this.operationLogService = operationLogService;
    }

    public record LoginRequest(String username, String password) {}

    public record ChangePasswordRequest(String oldPassword, String newPassword) {}

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody LoginRequest request,
                                                     HttpServletRequest httpRequest,
                                                     HttpServletResponse httpResponse) {
        if (request.username() == null || request.username().isBlank()
                || request.password() == null || request.password().isEmpty()) {
            throw new BusinessException("用户名和密码不能为空");
        }

        Authentication authentication = authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken.unauthenticated(request.username(), request.password()));

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
        securityContextRepository.saveContext(context, httpRequest, httpResponse);

        // 防会话固定：登录成功后换发 session id（属性保留）
        if (httpRequest.getSession(false) != null) {
            httpRequest.changeSessionId();
        }

        upgradeLegacyPassword(request.username(), request.password());
        User loginUser = userRepository.findByUsername(request.username()).orElse(null);
        operationLogService.log("登录", "session", loginUser == null ? null : loginUser.getId(), "登录成功");
        return ResponseEntity.ok(userInfo(request.username()));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(HttpServletRequest request, HttpServletResponse response) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        operationLogService.log("退出", "session", null, "退出登录");
        new SecurityContextLogoutHandler().logout(request, response, authentication);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> me(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(userInfo(authentication.getName()));
    }

    /** 当前登录用户修改自己的密码 */
    @PostMapping("/password")
    public ResponseEntity<Void> changePassword(@RequestBody ChangePasswordRequest request,
                                               Authentication authentication) {
        passwordService.changePassword(authentication.getName(), request.oldPassword(), request.newPassword());
        return ResponseEntity.ok().build();
    }

    /** 历史明文密码在登录成功后自动升级为 BCrypt */
    private void upgradeLegacyPassword(String username, String rawPassword) {
        userRepository.findByUsername(username).ifPresent(user -> {
            String stored = user.getPassword();
            if (stored != null && !stored.startsWith("$2")) {
                user.setPassword(passwordEncoder.encode(rawPassword));
                userRepository.save(user);
            }
        });
    }

    private Map<String, Object> userInfo(String username) {
        User user = userRepository.findByUsername(username).orElse(null);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", user == null ? null : user.getId());
        data.put("username", username);
        data.put("role", user == null ? null : user.getRole());
        data.put("warehouse", user == null ? null : user.getWarehouse());
        return data;
    }
}
