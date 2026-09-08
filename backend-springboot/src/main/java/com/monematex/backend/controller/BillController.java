package com.monematex.backend.controller;

import com.monematex.backend.dto.BillDto;
import com.monematex.backend.service.BillService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/bills")
@CrossOrigin(origins = "*")
public class BillController {

    private final BillService billService;

    public BillController(BillService billService) {
        this.billService = billService;
    }

    private String extractUserId(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() != null) {
            return authentication.getPrincipal().toString();
        }
        return "usr_demo";
    }

    @GetMapping
    public ResponseEntity<List<BillDto>> getBills(Authentication authentication) {
        String userId = extractUserId(authentication);
        List<BillDto> bills = billService.getBills(userId);
        return ResponseEntity.ok(bills);
    }

    @PostMapping
    public ResponseEntity<?> createBill(@RequestBody BillDto dto, Authentication authentication) {
        String userId = extractUserId(authentication);
        if (dto.getName() == null || dto.getAmount() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Name and amount are required."));
        }
        BillDto created = billService.createBill(userId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteBill(@PathVariable String id, Authentication authentication) {
        String userId = extractUserId(authentication);
        billService.deleteBill(id, userId);
        return ResponseEntity.ok(Map.of("success", true, "message", "Bill deleted."));
    }
}
