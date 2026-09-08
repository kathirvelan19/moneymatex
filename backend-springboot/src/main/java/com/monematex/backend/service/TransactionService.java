package com.monematex.backend.service;

import com.monematex.backend.dto.TransactionDto;
import com.monematex.backend.model.Transaction;
import com.monematex.backend.model.Wallet;
import com.monematex.backend.repository.TransactionRepository;
import com.monematex.backend.repository.WalletRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final WalletRepository walletRepository;

    public TransactionService(TransactionRepository transactionRepository, WalletRepository walletRepository) {
        this.transactionRepository = transactionRepository;
        this.walletRepository = walletRepository;
    }

    public List<TransactionDto> getTransactions(String userId) {
        List<Transaction> transactions = transactionRepository.findByUserIdOrderByDateDesc(userId);
        return transactions.stream().map(r -> new TransactionDto(
                r.getId(),
                r.getTitle(),
                r.getCategory(),
                r.getAmount(),
                r.getIsExpense(),
                r.getDate(),
                r.getPaymentMethod(),
                r.getWalletId() != null ? r.getWalletId() : "",
                r.getNotes() != null ? r.getNotes() : ""
        )).collect(Collectors.toList());
    }

    @Transactional
    public TransactionDto createTransaction(String userId, TransactionDto dto) {
        String txId = dto.getId() != null && !dto.getId().trim().isEmpty()
                ? dto.getId()
                : "tx_" + System.currentTimeMillis();
        String createdAt = LocalDateTime.now().format(DateTimeFormatter.ISO_DATE_TIME);

        Transaction entity = new Transaction(
                txId,
                userId,
                dto.getTitle(),
                dto.getCategory(),
                dto.getAmount() != null ? dto.getAmount() : 0.0,
                dto.getIsExpense() != null ? dto.getIsExpense() : true,
                dto.getDate() != null ? dto.getDate() : createdAt,
                dto.getPaymentMethod() != null ? dto.getPaymentMethod() : "Wallet",
                dto.getWalletId() != null ? dto.getWalletId() : "",
                dto.getNotes() != null ? dto.getNotes() : "",
                createdAt
        );

        transactionRepository.save(entity);

        if (dto.getWalletId() != null && !dto.getWalletId().trim().isEmpty()) {
            Optional<Wallet> walletOpt = walletRepository.findByIdAndUserId(dto.getWalletId(), userId);
            if (walletOpt.isPresent()) {
                Wallet wallet = walletOpt.get();
                double delta = Boolean.TRUE.equals(dto.getIsExpense()) ? -dto.getAmount() : dto.getAmount();
                double newBalance = Math.max(0.0, wallet.getBalance() + delta);
                wallet.setBalance(newBalance);
                walletRepository.save(wallet);
            }
        }

        dto.setId(txId);
        return dto;
    }

    @Transactional
    public boolean deleteTransaction(String id, String userId) {
        if (transactionRepository.existsById(id)) {
            transactionRepository.deleteByIdAndUserId(id, userId);
            return true;
        }
        return false;
    }
}
