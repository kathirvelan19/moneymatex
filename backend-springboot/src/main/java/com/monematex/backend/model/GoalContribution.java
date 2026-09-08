package com.monematex.backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "goal_contributions")
public class GoalContribution {

    @Id
    private String id;
    private String goalId;
    private String userId;
    private Double amount;
    private String date;
    private String note;

    public GoalContribution() {}

    public GoalContribution(String id, String goalId, String userId, Double amount, String date, String note) {
        this.id = id;
        this.goalId = goalId;
        this.userId = userId;
        this.amount = amount;
        this.date = date;
        this.note = note;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getGoalId() { return goalId; }
    public void setGoalId(String goalId) { this.goalId = goalId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
