package com.warehouse.config;

import com.warehouse.repository.UserRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    /**
     * 前后端同源的 SPA：静态页面放行，/api/** 需要登录；未登录统一返回 401 JSON，
     * 由前端弹出登录框，不做 302 跳转。
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http,
                                                   SecurityContextRepository securityContextRepository) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable())
                .logout(logout -> logout.disable())
                .securityContext(sc -> sc.securityContextRepository(securityContextRepository))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/css/**", "/js/**", "/vendor/**", "/favicon.ico", "/error").permitAll()
                        .requestMatchers("/api/auth/login").permitAll()
                        .requestMatchers("/api/**").authenticated()
                        .anyRequest().permitAll())
                .exceptionHandling(ex -> ex
                        .defaultAuthenticationEntryPointFor(
                                (request, response, authException) -> writeJson(response, HttpStatus.UNAUTHORIZED,
                                        "{\"message\":\"未登录或会话已过期\"}"),
                                request -> request.getRequestURI().startsWith("/api/"))
                        .defaultAccessDeniedHandlerFor(
                                (request, response, deniedException) -> writeJson(response, HttpStatus.FORBIDDEN,
                                        "{\"message\":\"没有权限\"}"),
                                request -> request.getRequestURI().startsWith("/api/")));
        return http.build();
    }

    private static void writeJson(jakarta.servlet.http.HttpServletResponse response,
                                  HttpStatus status, String body) throws java.io.IOException {
        response.setStatus(status.value());
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(body);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new LegacyAwarePasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService(UserRepository userRepository) {
        return username -> userRepository.findByUsername(username)
                .map(user -> org.springframework.security.core.userdetails.User
                        .withUsername(user.getUsername())
                        .password(user.getPassword() == null ? "" : user.getPassword())
                        .roles(roleOf(user.getRole()))
                        .build())
                .orElseThrow(() -> new UsernameNotFoundException("用户不存在：" + username));
    }

    private static String roleOf(String role) {
        return role == null || role.isBlank() ? "USER" : role.replace("ROLE_", "");
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager();
    }

    @Bean
    public SecurityContextRepository securityContextRepository() {
        return new HttpSessionSecurityContextRepository();
    }
}
