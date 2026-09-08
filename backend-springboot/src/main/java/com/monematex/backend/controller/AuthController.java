package com.monematex.backend.controller;

import com.monematex.backend.dto.AuthResponse;
import com.monematex.backend.dto.LoginRequest;
import com.monematex.backend.dto.SignUpRequest;
import com.monematex.backend.model.User;
import com.monematex.backend.service.JwtService;
import com.monematex.backend.service.PasswordResetService;
import com.monematex.backend.service.ProfileService;
import com.monematex.backend.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final UserService userService;
    private final JwtService jwtService;
    private final PasswordResetService passwordResetService;
    private final ProfileService profileService;

    public AuthController(UserService userService, JwtService jwtService,
                          PasswordResetService passwordResetService, ProfileService profileService) {
        this.userService = userService;
        this.jwtService = jwtService;
        this.passwordResetService = passwordResetService;
        this.profileService = profileService;
    }

    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getAuthStatus() {
        return ResponseEntity.ok(Map.of(
                "status", "online",
                "service", "MoneyMateX Spring Boot Unified Backend",
                "authMethods", Map.of("emailPassword", true, "googleSignIn", true)
        ));
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignUpRequest request) {
        if (request.getName() == null || request.getEmail() == null || request.getPassword() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Name, email, and password are required."));
        }

        Optional<User> existing = userService.findByEmail(request.getEmail());
        if (existing.isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("error", "User with this email already exists."));
        }

        User user = userService.createUser(request.getName(), request.getEmail(), request.getPassword());
        String token = jwtService.generateToken(user.getId(), user.getEmail());

        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "token", token,
                "user", Map.of("id", user.getId(), "email", user.getEmail(), "name", user.getName())
        ));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        if (request.getEmail() == null || request.getPassword() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email and password are required."));
        }

        Optional<User> userOpt = userService.findByEmail(request.getEmail());
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid email or password."));
        }

        User user = userOpt.get();
        if (!userService.validatePassword(user, request.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid email or password."));
        }

        String token = jwtService.generateToken(user.getId(), user.getEmail());

        return ResponseEntity.ok(Map.of(
                "token", token,
                "user", Map.of("id", user.getId(), "email", user.getEmail(), "name", user.getName())
        ));
    }

    @GetMapping("/me")
    public ResponseEntity<?> me(Authentication authentication) {
        if (authentication == null || authentication.getPrincipal() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Unauthorized"));
        }

        String userId = authentication.getPrincipal().toString();
        Optional<User> userOpt = userService.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "User not found."));
        }

        User user = userOpt.get();
        return ResponseEntity.ok(Map.of("user", Map.of(
                "id", user.getId(),
                "email", user.getEmail(),
                "name", user.getName(),
                "created_at", user.getCreatedAt() != null ? user.getCreatedAt().toString() : ""
        )));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (email == null || email.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email address is required."));
        }

        String code = passwordResetService.createResetCode(email);
        System.out.println("[MONEYMATEX SPRING BOOT SECURITY] Password Reset OTP generated for " + email + ": [" + code + "]");

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Verification code sent to your email."
        ));
    }

    @PostMapping("/verify-reset-code")
    public ResponseEntity<?> verifyResetCode(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String code = body.get("code");
        if (email == null || code == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email and verification code are required."));
        }

        Optional<String> tokenOpt = passwordResetService.verifyCode(email, code);
        if (tokenOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Incorrect or expired verification code. Please try again."));
        }

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Code verified successfully.",
                "resetToken", tokenOpt.get()
        ));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String resetToken = body.get("resetToken");
        String newPassword = body.get("newPassword");

        if (email == null || resetToken == null || newPassword == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email, reset token, and new password are required."));
        }

        boolean valid = passwordResetService.validateResetSession(email, resetToken);
        if (!valid) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid or expired password reset session."));
        }

        Optional<User> userOpt = userService.findByEmail(email);
        if (userOpt.isPresent()) {
            userService.updatePassword(userOpt.get(), newPassword);
        }

        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Password updated successfully. You can now log in with your new password."
        ));
    }
}