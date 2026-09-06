package com.monematex.backend.service;

import com.monematex.backend.model.PasswordReset;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class PasswordResetService {

    private final Map<String, PasswordReset> resetsByEmail = new ConcurrentHashMap<>();
    private final Map<String, PasswordReset> resetsByToken = new ConcurrentHashMap<>();
    private final SecureRandom random = new SecureRandom();

    public String createResetCode(String email) {
        String code = String.format("%06d", random.nextInt(1000000));
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(10); // 10 minute expiration

        PasswordReset reset = new PasswordReset(email.toLowerCase().trim(), code, expiresAt);
        resetsByEmail.put(email.toLowerCase().trim(), reset);

        System.out.println("[MONEYMATEX SECURITY] Password Reset Code generated for " + email + ": [" + code + "]");
        return code;
    }

    public Optional<String> verifyCode(String email, String code) {
        PasswordReset reset = resetsByEmail.get(email.toLowerCase().trim());
        if (reset == null) return Optional.empty();

        if (reset.getExpiresAt().isBefore(LocalDateTime.now())) {
            resetsByEmail.remove(email.toLowerCase().trim());
            return Optional.empty();
        }

        if (!reset.getCode().equals(code.trim())) {
            return Optional.empty();
        }

        String resetToken = "rst_" + UUID.randomUUID().toString();
        reset.setResetToken(resetToken);
        reset.setVerified(true);

        resetsByToken.put(resetToken, reset);
        return Optional.of(resetToken);
    }

    public boolean validateResetTokenAndConsume(String email, String resetToken) {
        PasswordReset reset = resetsByToken.get(resetToken);
        if (reset == null) return false;

        if (!reset.getEmail().equalsIgnoreCase(email.trim())) return false;
        if (!reset.isVerified()) return false;
        if (reset.getExpiresAt().isBefore(LocalDateTime.now())) return false;

        resetsByToken.remove(resetToken);
        resetsByEmail.remove(email.toLowerCase().trim());
        return true;
    }
}
