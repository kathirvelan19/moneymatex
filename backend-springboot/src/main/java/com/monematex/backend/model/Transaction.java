package com.monematex.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "transactions")
public class Transaction {

    @Id
    private String id;
    private String userId;
    private String title;
    private String category;
    private Double amount;
    private Boolean isExpense;
    private String date;
    private String paymentMethod;
    private String walletId;
    private String notes;
    private String createdAt;

    public Transaction() {}

    public Transaction(String id, String userId, String title, String category, Double amount,
                       Boolean isExpense, String date, String paymentMethod, String walletId,
                       String notes, String createdAt) {
        this.id = id;
        this.userId = userId;
        this.title = title;
        this.category = category;
        this.amount = amount;
        this.isExpense = isExpense;
        this.date = date;
        this.paymentMethod = paymentMethod;
        this.walletId = walletId;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public Boolean getIsExpense() { return isExpense; }
    public void setIsExpense(Boolean isExpense) { this.isExpense = isExpense; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getWalletId() { return walletId; }
    public void setWalletId(String walletId) { this.walletId = walletId; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
