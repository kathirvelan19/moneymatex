package com.monematex.backend.controller;

import com.monematex.backend.service.OCRService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/ocr")
@CrossOrigin(origins = "*")
public class OCRController {

    private final OCRService ocrService;

    public OCRController(OCRService ocrService) {
        this.ocrService = ocrService;
    }

    @PostMapping("/scan-receipt")
    public ResponseEntity<?> scanReceipt(@RequestBody Map<String, String> body) {
        String imageBase64 = body.get("imageDataUrl");
        if (imageBase64 == null) {
            imageBase64 = body.get("image");
        }
        if (imageBase64 == null || imageBase64.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "imageDataUrl is required."));
        }

        try {
            Map<String, Object> result = ocrService.scanReceipt(imageBase64);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}
