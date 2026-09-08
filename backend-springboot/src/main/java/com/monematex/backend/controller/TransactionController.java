package com.monematex.backend.controller;

import com.monematex.backend.dto.TransactionDto;
import com.monematex.backend.service.TransactionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/transactions")
@CrossOrigin(origins = "*")
public class TransactionController {

    private final TransactionService transactionService;

    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    private String extractUserId(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() != null) {
            return authentication.getPrincipal().toString();
        }
        return "usr_demo";
    }

    @GetMapping
    public ResponseEntity<List<TransactionDto>> getTransactions(Authentication authentication) {
        String userId = extractUserId(authentication);
        List<TransactionDto> transactions = transactionService.getTransactions(userId);
        return ResponseEntity.ok(transactions);
    }

    @PostMapping
    public ResponseEntity<?> createTransaction(@RequestBody TransactionDto dto, Authentication authentication) {
        String userId = extractUserId(authentication);
        if (dto.getTitle() == null || dto.getAmount() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Title and amount are required."));
        }
        TransactionDto created = transactionService.createTransaction(userId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTransaction(@PathVariable String id, Authentication authentication) {
        String userId = extractUserId(authentication);
        boolean success = transactionService.deleteTransaction(id, userId);
        if (!success) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Transaction not found."));
        }
        return ResponseEntity.ok(Map.of("success", true, "message", "Transaction deleted."));
    }
}
