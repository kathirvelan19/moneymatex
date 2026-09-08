package com.monematex.backend.repository;

import com.monematex.backend.model.Bill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BillRepository extends JpaRepository<Bill, String> {
    List<Bill> findByUserId(String userId);
    void deleteByIdAndUserId(String id, String userId);
}
