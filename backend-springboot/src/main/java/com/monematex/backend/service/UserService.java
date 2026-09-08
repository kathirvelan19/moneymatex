package com.monematex.backend.service;

import com.monematex.backend.model.User;
import com.monematex.backend.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public Optional<User> findByEmail(String email) {
        if (email == null) return Optional.empty();
        return userRepository.findByEmailIgnoreCase(email.trim());
    }

    public Optional<User> findById(String id) {
        if (id == null) return Optional.empty();
        return userRepository.findById(id);
    }

    public User createUser(String name, String email, String password) {
        String userId = "usr_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 5);
        String hash = passwordEncoder.encode(password);
        User user = new User(userId, email.toLowerCase().trim(), name, hash, LocalDateTime.now());
        return userRepository.save(user);
    }

    public boolean validatePassword(User user, String rawPassword) {
        return passwordEncoder.matches(rawPassword, user.getPasswordHash());
    }

    public void updatePassword(User user, String newPassword) {
        String hash = passwordEncoder.encode(newPassword);
        user.setPasswordHash(hash);
        userRepository.save(user);
    }
}
