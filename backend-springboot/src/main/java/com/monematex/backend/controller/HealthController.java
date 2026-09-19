package com.monematex.backend.controller;

import com.monematex.backend.service.OCRService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
@CrossOrigin(origins = "*")
public class HealthController {

    private final OCRService ocrService;

    public HealthController(OCRService ocrService) {
        this.ocrService = ocrService;
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "UP");
        response.put("service", "MoneyMateX Spring Boot Unified Production API");
        response.put("timestamp", Instant.now().toString());
        // Confirms key is configured — NEVER exposes the actual key value
        response.put("geminiConfigured", ocrService.isGeminiConfigured());
        return ResponseEntity.ok(response);
    }
}
