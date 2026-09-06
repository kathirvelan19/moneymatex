package com.monematex.backend.service;

import com.monematex.backend.model.User;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class UserService {

    private final Map<String, User> usersById = new ConcurrentHashMap<>();
    private final Map<String, User> usersByEmail = new ConcurrentHashMap<>();
    private final PasswordEncoder passwordEncoder;

    public UserService(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    public Optional<User> findByEmail(String email) {
        if (email == null) return Optional.empty();
        return Optional.ofNullable(usersByEmail.get(email.toLowerCase().trim()));
    }

    public Optional<User> findById(String id) {
        if (id == null) return Optional.empty();
        return Optional.ofNullable(usersById.get(id));
    }

    public User createUser(String name, String email, String password) {
        String userId = "usr_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 5);
        String hash = passwordEncoder.encode(password);
        User user = new User(userId, email.toLowerCase().trim(), name, hash, LocalDateTime.now());

        usersById.put(userId, user);
        usersByEmail.put(email.toLowerCase().trim(), user);

        return user;
    }

    public boolean validatePassword(User user, String rawPassword) {
        return passwordEncoder.matches(rawPassword, user.getPasswordHash());
    }

    public void updatePassword(User user, String newPassword) {
        String hash = passwordEncoder.encode(newPassword);
        user.setPasswordHash(hash);
        usersById.put(user.getId(), user);
        usersByEmail.put(user.getEmail().toLowerCase().trim(), user);
    }
}
