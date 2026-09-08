package com.monematex.backend.repository;

import com.monematex.backend.model.Wallet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, String> {
    List<Wallet> findByUserId(String userId);
    Optional<Wallet> findByIdAndUserId(String id, String userId);
    void deleteByIdAndUserId(String id, String userId);
}
