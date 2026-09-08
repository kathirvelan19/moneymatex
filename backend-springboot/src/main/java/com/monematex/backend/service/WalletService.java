package com.monematex.backend.service;

import com.monematex.backend.dto.WalletDto;
import com.monematex.backend.model.Wallet;
import com.monematex.backend.repository.WalletRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class WalletService {

    private final WalletRepository walletRepository;

    public WalletService(WalletRepository walletRepository) {
        this.walletRepository = walletRepository;
    }

    public List<WalletDto> getWallets(String userId) {
        List<Wallet> wallets = walletRepository.findByUserId(userId);
        return wallets.stream().map(w -> new WalletDto(
                w.getId(),
                w.getName(),
                w.getType(),
                w.getProvider(),
                w.getBalance(),
                w.getIsPrimary(),
                w.getTrackingMethod(),
                w.getCreatedAt()
        )).collect(Collectors.toList());
    }

    @Transactional
    public WalletDto createWallet(String userId, WalletDto dto) {
        String walletId = dto.getId() != null && !dto.getId().trim().isEmpty()
                ? dto.getId()
                : "wlt_" + System.currentTimeMillis();
        String createdAt = LocalDateTime.now().format(DateTimeFormatter.ISO_DATE_TIME);

        if (Boolean.TRUE.equals(dto.getIsPrimary())) {
            List<Wallet> existingWallets = walletRepository.findByUserId(userId);
            for (Wallet w : existingWallets) {
                if (Boolean.TRUE.equals(w.getIsPrimary())) {
                    w.setIsPrimary(false);
                    walletRepository.save(w);
                }
            }
        }

        Wallet entity = new Wallet(
                walletId,
                userId,
                dto.getName(),
                dto.getType(),
                dto.getProvider(),
                dto.getBalance() != null ? dto.getBalance() : 0.0,
                dto.getIsPrimary() != null ? dto.getIsPrimary() : false,
                dto.getTrackingMethod() != null ? dto.getTrackingMethod() : "Manual",
                createdAt
        );

        walletRepository.save(entity);

        dto.setId(walletId);
        dto.setCreatedAt(createdAt);
        return dto;
    }

    @Transactional
    public void deleteWallet(String id, String userId) {
        walletRepository.deleteByIdAndUserId(id, userId);
    }
}
