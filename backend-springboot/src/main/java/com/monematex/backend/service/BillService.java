package com.monematex.backend.service;

import com.monematex.backend.dto.BillDto;
import com.monematex.backend.model.Bill;
import com.monematex.backend.repository.BillRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class BillService {

    private final BillRepository billRepository;

    public BillService(BillRepository billRepository) {
        this.billRepository = billRepository;
    }

    public List<BillDto> getBills(String userId) {
        List<Bill> bills = billRepository.findByUserId(userId);
        return bills.stream().map(b -> new BillDto(
                b.getId(),
                b.getName(),
                b.getCategory(),
                b.getAmount(),
                b.getDueDate(),
                b.getFrequency(),
                b.getPaymentMethod(),
                b.getWalletId() != null ? b.getWalletId() : "",
                b.getIsRecurring(),
                b.getReminderEnabled(),
                b.getReminderTime(),
                b.getStatus(),
                b.getCreatedAt(),
                b.getUpdatedAt()
        )).collect(Collectors.toList());
    }

    @Transactional
    public BillDto createBill(String userId, BillDto dto) {
        String billId = dto.getId() != null && !dto.getId().trim().isEmpty()
                ? dto.getId()
                : "bill_" + System.currentTimeMillis();
        String now = LocalDateTime.now().format(DateTimeFormatter.ISO_DATE_TIME);

        Bill bill = new Bill(
                billId,
                userId,
                dto.getName(),
                dto.getCategory(),
                dto.getAmount() != null ? dto.getAmount() : 0.0,
                dto.getDueDate(),
                dto.getFrequency(),
                dto.getPaymentMethod(),
                dto.getWalletId() != null ? dto.getWalletId() : "",
                dto.getIsRecurring() != null ? dto.getIsRecurring() : false,
                dto.getReminderEnabled() != null ? dto.getReminderEnabled() : false,
                dto.getReminderTime() != null ? dto.getReminderTime() : "09:00 AM",
                "Upcoming",
                now,
                now
        );

        billRepository.save(bill);

        dto.setId(billId);
        dto.setStatus("Upcoming");
        dto.setCreatedAt(now);
        dto.setUpdatedAt(now);
        return dto;
    }

    @Transactional
    public void deleteBill(String id, String userId) {
        billRepository.deleteByIdAndUserId(id, userId);
    }
}
