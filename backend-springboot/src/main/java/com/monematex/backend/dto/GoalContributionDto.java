package com.monematex.backend.dto;

public class GoalContributionDto {
    private String id;
    private String goalId;
    private Double amount;
    private String date;
    private String note;

    public GoalContributionDto() {}

    public GoalContributionDto(String id, String goalId, Double amount, String date, String note) {
        this.id = id;
        this.goalId = goalId;
        this.amount = amount;
        this.date = date;
        this.note = note;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getGoalId() { return goalId; }
    public void setGoalId(String goalId) { this.goalId = goalId; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
