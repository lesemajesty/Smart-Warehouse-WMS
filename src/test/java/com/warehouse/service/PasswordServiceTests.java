package com.warehouse.service;

import com.warehouse.entity.User;
import com.warehouse.exception.BusinessException;
import com.warehouse.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@Transactional
class PasswordServiceTests {

    @Autowired private PasswordService passwordService;
    @Autowired private UserRepository userRepository;
    @Autowired private PasswordEncoder passwordEncoder;

    private User newUser(String username, String rawPassword) {
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(rawPassword));
        user.setRole("WAREHOUSE");
        user.setCreateTime(LocalDateTime.now());
        return userRepository.save(user);
    }

    private String storedPassword(String username) {
        return userRepository.findByUsername(username).orElseThrow().getPassword();
    }

    @Test
    void changePasswordWithCorrectOldPassword() {
        newUser("pw-user-1", "oldpass");

        passwordService.changePassword("pw-user-1", "oldpass", "newpass123");

        assertThat(passwordEncoder.matches("newpass123", storedPassword("pw-user-1"))).isTrue();
        assertThat(passwordEncoder.matches("oldpass", storedPassword("pw-user-1"))).isFalse();
    }

    @Test
    void changePasswordRejectsWrongOldPassword() {
        newUser("pw-user-2", "oldpass");

        assertThatThrownBy(() -> passwordService.changePassword("pw-user-2", "wrong", "newpass123"))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("当前密码不正确");

        assertThat(passwordEncoder.matches("oldpass", storedPassword("pw-user-2"))).isTrue();
    }

    @Test
    void changePasswordRejectsShortPassword() {
        newUser("pw-user-3", "oldpass");

        assertThatThrownBy(() -> passwordService.changePassword("pw-user-3", "oldpass", "123"))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("至少 6 位");
    }

    @Test
    void resetPasswordOverwritesWithoutOldPassword() {
        User user = newUser("pw-user-4", "oldpass");

        passwordService.resetPassword(user.getId(), "resetpass");

        assertThat(passwordEncoder.matches("resetpass", storedPassword("pw-user-4"))).isTrue();
        assertThat(passwordEncoder.matches("oldpass", storedPassword("pw-user-4"))).isFalse();
    }
}
