package com.monematex.backend.dto;

public class ProfileDto {
    private String name;
    private String email;
    private String occupation;
    private String financialPriority;
    private Double monthlyIncome;
    private Double additionalIncome;
    private Double monthlyExpensesEstimate;
    private Double currentSavings;
    private Double debtAmount;
    private String primaryGoal;
    private Double goalTargetAmount;

    public ProfileDto() {}

    public ProfileDto(String name, String email, String occupation, String financialPriority,
                      Double monthlyIncome, Double additionalIncome, Double monthlyExpensesEstimate,
                      Double currentSavings, Double debtAmount, String primaryGoal, Double goalTargetAmount) {
        this.name = name;
        this.email = email;
        this.occupation = occupation;
        this.financialPriority = financialPriority;
        this.monthlyIncome = monthlyIncome;
        this.additionalIncome = additionalIncome;
        this.monthlyExpensesEstimate = monthlyExpensesEstimate;
        this.currentSavings = currentSavings;
        this.debtAmount = debtAmount;
        this.primaryGoal = primaryGoal;
        this.goalTargetAmount = goalTargetAmount;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getOccupation() { return occupation; }
    public void setOccupation(String occupation) { this.occupation = occupation; }

    public String getFinancialPriority() { return financialPriority; }
    public void setFinancialPriority(String financialPriority) { this.financialPriority = financialPriority; }

    public Double getMonthlyIncome() { return monthlyIncome; }
    public void setMonthlyIncome(Double monthlyIncome) { this.monthlyIncome = monthlyIncome; }

    public Double getAdditionalIncome() { return additionalIncome; }
    public void setAdditionalIncome(Double additionalIncome) { this.additionalIncome = additionalIncome; }

    public Double getMonthlyExpensesEstimate() { return monthlyExpensesEstimate; }
    public void setMonthlyExpensesEstimate(Double monthlyExpensesEstimate) { this.monthlyExpensesEstimate = monthlyExpensesEstimate; }

    public Double getCurrentSavings() { return currentSavings; }
    public void setCurrentSavings(Double currentSavings) { this.currentSavings = currentSavings; }

    public Double getDebtAmount() { return debtAmount; }
    public void setDebtAmount(Double debtAmount) { this.debtAmount = debtAmount; }

    public String getPrimaryGoal() { return primaryGoal; }
    public void setPrimaryGoal(String primaryGoal) { this.primaryGoal = primaryGoal; }

    public Double getGoalTargetAmount() { return goalTargetAmount; }
    public void setGoalTargetAmount(Double goalTargetAmount) { this.goalTargetAmount = goalTargetAmount; }
}
