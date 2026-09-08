package com.monematex.backend.dto;

import java.util.List;

public class GoalDto {
    private String id;
    private String name;
    private Double targetAmount;
    private Double savedAmount;
    private String targetDate;
    private String category;
    private String priority;
    private String status;
    private String notes;
    private String createdAt;
    private String updatedAt;
    private List<GoalContributionDto> contributions;

    public GoalDto() {}

    public GoalDto(String id, String name, Double targetAmount, Double savedAmount, String targetDate,
                   String category, String priority, String status, String notes, String createdAt,
                   String updatedAt, List<GoalContributionDto> contributions) {
        this.id = id;
        this.name = name;
        this.targetAmount = targetAmount;
        this.savedAmount = savedAmount;
        this.targetDate = targetDate;
        this.category = category;
        this.priority = priority;
        this.status = status;
        this.notes = notes;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.contributions = contributions;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Double getTargetAmount() { return targetAmount; }
    public void setTargetAmount(Double targetAmount) { this.targetAmount = targetAmount; }

    public Double getSavedAmount() { return savedAmount; }
    public void setSavedAmount(Double savedAmount) { this.savedAmount = savedAmount; }

    public String getTargetDate() { return targetDate; }
    public void setTargetDate(String targetDate) { this.targetDate = targetDate; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }

    public List<GoalContributionDto> getContributions() { return contributions; }
    public void setContributions(List<GoalContributionDto> contributions) { this.contributions = contributions; }
}
