package com.monematex.backend.repository;

import com.monematex.backend.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, String> {
    List<Transaction> findByUserIdOrderByDateDesc(String userId);
    void deleteByIdAndUserId(String id, String userId);
}
