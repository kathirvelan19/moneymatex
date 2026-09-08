package com.monematex.backend.controller;

import com.monematex.backend.dto.ProfileDto;
import com.monematex.backend.service.ProfileService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/profile")
@CrossOrigin(origins = "*")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    private String extractUserId(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() != null) {
            return authentication.getPrincipal().toString();
        }
        return "usr_demo";
    }

    @GetMapping
    public ResponseEntity<ProfileDto> getProfile(Authentication authentication) {
        String userId = extractUserId(authentication);
        ProfileDto profile = profileService.getProfile(userId);
        return ResponseEntity.ok(profile);
    }

    @PutMapping
    public ResponseEntity<?> updateProfile(@RequestBody ProfileDto dto, Authentication authentication) {
        String userId = extractUserId(authentication);
        profileService.upsertProfile(userId, dto);
        return ResponseEntity.ok(Map.of("success", true, "message", "Profile updated."));
    }
}
