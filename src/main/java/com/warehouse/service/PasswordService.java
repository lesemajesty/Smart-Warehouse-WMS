package com.warehouse.service;

import com.warehouse.entity.User;
import com.warehouse.exception.BusinessException;
import com.warehouse.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 密码修改/重置。新密码统一 BCrypt 存储。
 */
@Service
public class PasswordService {

    private static final int MIN_LENGTH = 6;
    private static final int MAX_LENGTH = 64;

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public PasswordService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /** 用户自助修改：必须校验原密码 */
    @Transactional
    public void changePassword(String username, String oldPassword, String newPassword) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException("用户不存在"));

        if (oldPassword == null || oldPassword.isEmpty()) {
            throw new BusinessException("请输入当前密码");
        }
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new BusinessException("当前密码不正确");
        }
        if (newPassword != null && newPassword.equals(oldPassword)) {
            throw new BusinessException("新密码不能与当前密码相同");
        }
        applyNewPassword(user, newPassword);
    }

    /** 管理员重置他人密码，不需要原密码 */
    @Transactional
    public void resetPassword(Long userId, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("用户不存在"));
        applyNewPassword(user, newPassword);
    }

    private void applyNewPassword(User user, String newPassword) {
        if (newPassword == null || newPassword.length() < MIN_LENGTH) {
            throw new BusinessException("新密码至少 " + MIN_LENGTH + " 位");
        }
        if (newPassword.length() > MAX_LENGTH) {
            throw new BusinessException("新密码不能超过 " + MAX_LENGTH + " 位");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
}
