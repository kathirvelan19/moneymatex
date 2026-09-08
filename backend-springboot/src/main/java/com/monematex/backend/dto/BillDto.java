package com.monematex.backend.dto;

public class BillDto {
    private String id;
    private String name;
    private String category;
    private Double amount;
    private String dueDate;
    private String frequency;
    private String paymentMethod;
    private String walletId;
    private Boolean isRecurring;
    private Boolean reminderEnabled;
    private String reminderTime;
    private String status;
    private String createdAt;
    private String updatedAt;

    public BillDto() {}

    public BillDto(String id, String name, String category, Double amount, String dueDate, String frequency,
                   String paymentMethod, String walletId, Boolean isRecurring, Boolean reminderEnabled,
                   String reminderTime, String status, String createdAt, String updatedAt) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.amount = amount;
        this.dueDate = dueDate;
        this.frequency = frequency;
        this.paymentMethod = paymentMethod;
        this.walletId = walletId;
        this.isRecurring = isRecurring;
        this.reminderEnabled = reminderEnabled;
        this.reminderTime = reminderTime;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public String getDueDate() { return dueDate; }
    public void setDueDate(String dueDate) { this.dueDate = dueDate; }

    public String getFrequency() { return frequency; }
    public void setFrequency(String frequency) { this.frequency = frequency; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getWalletId() { return walletId; }
    public void setWalletId(String walletId) { this.walletId = walletId; }

    public Boolean getIsRecurring() { return isRecurring; }
    public void setIsRecurring(Boolean isRecurring) { this.isRecurring = isRecurring; }

    public Boolean getReminderEnabled() { return reminderEnabled; }
    public void setReminderEnabled(Boolean reminderEnabled) { this.reminderEnabled = reminderEnabled; }

    public String getReminderTime() { return reminderTime; }
    public void setReminderTime(String reminderTime) { this.reminderTime = reminderTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
