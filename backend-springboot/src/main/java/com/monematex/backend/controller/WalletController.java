package com.monematex.backend.controller;

import com.monematex.backend.dto.WalletDto;
import com.monematex.backend.service.WalletService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/wallets")
@CrossOrigin(origins = "*")
public class WalletController {

    private final WalletService walletService;

    public WalletController(WalletService walletService) {
        this.walletService = walletService;
    }

    private String extractUserId(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() != null) {
            return authentication.getPrincipal().toString();
        }
        return "usr_demo";
    }

    @GetMapping
    public ResponseEntity<List<WalletDto>> getWallets(Authentication authentication) {
        String userId = extractUserId(authentication);
        List<WalletDto> wallets = walletService.getWallets(userId);
        return ResponseEntity.ok(wallets);
    }

    @PostMapping
    public ResponseEntity<?> createWallet(@RequestBody WalletDto dto, Authentication authentication) {
        String userId = extractUserId(authentication);
        if (dto.getName() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Wallet name is required."));
        }
        WalletDto created = walletService.createWallet(userId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteWallet(@PathVariable String id, Authentication authentication) {
        String userId = extractUserId(authentication);
        walletService.deleteWallet(id, userId);
        return ResponseEntity.ok(Map.of("success", true, "message", "Wallet deleted."));
    }
}
