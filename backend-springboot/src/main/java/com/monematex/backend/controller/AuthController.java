package com.monematex.backend.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @GetMapping("/status")
    public ResponseEntity<String> getAuthStatus() {
        return ResponseEntity.ok(
                "Authentication is managed by Firebase Auth / Google Sign-In."
        );
    }

    @PostMapping("/signup")
    public ResponseEntity<String> signup() {
        return ResponseEntity.status(HttpStatus.GONE)
                .body("Legacy signup is deprecated. Please use Firebase Google Sign-In.");
    }

    @PostMapping("/login")
    public ResponseEntity<String> login() {
        return ResponseEntity.status(HttpStatus.GONE)
                .body("Legacy login is deprecated. Please use Firebase Google Sign-In.");
    }

    @GetMapping("/me")
    public ResponseEntity<String> me() {
        return ResponseEntity.status(HttpStatus.GONE)
                .body("Authentication is managed by Firebase Auth.");
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword() {
        return ResponseEntity.status(HttpStatus.GONE)
                .body("Password recovery is not available. MoneyMateX uses Google Sign-In.");
    }

    @PostMapping("/verify-reset-code")
    public ResponseEntity<String> verifyResetCode() {
        return ResponseEntity.status(HttpStatus.GONE)
                .body("Password reset is not available. MoneyMateX uses Google Sign-In.");
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword() {
        return ResponseEntity.status(HttpStatus.GONE)
                .body("Password reset is not available. MoneyMateX uses Google Sign-In.");
    }
}