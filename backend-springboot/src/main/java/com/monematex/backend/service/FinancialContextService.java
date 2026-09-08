package com.monematex.backend.service;

import com.monematex.backend.dto.BillDto;
import com.monematex.backend.dto.GoalDto;
import com.monematex.backend.dto.ProfileDto;
import com.monematex.backend.dto.TransactionDto;
import com.monematex.backend.dto.WalletDto;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class FinancialContextService {

    private final WalletService walletService;
    private final TransactionService transactionService;
    private final GoalService goalService;
    private final BillService billService;
    private final ProfileService profileService;

    public FinancialContextService(WalletService walletService,
                                   TransactionService transactionService,
                                   GoalService goalService,
                                   BillService billService,
                                   ProfileService profileService) {
        this.walletService = walletService;
        this.transactionService = transactionService;
        this.goalService = goalService;
        this.billService = billService;
        this.profileService = profileService;
    }

    public double getCurrentBalance(String userId) {
        List<WalletDto> wallets = walletService.getWallets(userId);
        return wallets.stream().mapToDouble(w -> w.getBalance() != null ? w.getBalance() : 0.0).sum();
    }

    public double getMonthlyIncome(String userId) {
        List<TransactionDto> transactions = transactionService.getTransactions(userId);
        double loggedIncome = transactions.stream()
                .filter(t -> Boolean.FALSE.equals(t.getIsExpense()))
                .mapToDouble(t -> t.getAmount() != null ? t.getAmount() : 0.0)
                .sum();
        if (loggedIncome > 0) return loggedIncome;

        ProfileDto profile = profileService.getProfile(userId);
        return profile.getMonthlyIncome() != null ? profile.getMonthlyIncome() : 0.0;
    }

    public double getMonthlyExpenses(String userId) {
        List<TransactionDto> transactions = transactionService.getTransactions(userId);
        return transactions.stream()
                .filter(t -> Boolean.TRUE.equals(t.getIsExpense()))
                .mapToDouble(t -> t.getAmount() != null ? t.getAmount() : 0.0)
                .sum();
    }

    public double getNetCashFlow(String userId) {
        return getMonthlyIncome(userId) - getMonthlyExpenses(userId);
    }

    public double getSavingsRate(String userId) {
        double income = getMonthlyIncome(userId);
        double net = getNetCashFlow(userId);
        if (income <= 0) return 0.0;
        return Math.min(Math.max((net / income) * 100.0, 0.0), 100.0);
    }

    public Map<String, Double> getCategorySpending(String userId) {
        List<TransactionDto> transactions = transactionService.getTransactions(userId);
        Map<String, Double> map = new HashMap<>();
        for (TransactionDto t : transactions) {
            if (Boolean.TRUE.equals(t.getIsExpense()) && t.getCategory() != null) {
                map.put(t.getCategory(), map.getOrDefault(t.getCategory(), 0.0) + (t.getAmount() != null ? t.getAmount() : 0.0));
            }
        }
        return map;
    }

    public Map<String, Object> getBudgetStatus(String userId) {
        double expenses = getMonthlyExpenses(userId);
        ProfileDto profile = profileService.getProfile(userId);
        double targetBudget = (profile.getMonthlyExpensesEstimate() != null && profile.getMonthlyExpensesEstimate() > 0)
                ? profile.getMonthlyExpensesEstimate()
                : 50000.0;
        double usage = targetBudget > 0 ? (expenses / targetBudget) * 100.0 : 0.0;

        Map<String, Object> res = new HashMap<>();
        res.put("targetBudget", targetBudget);
        res.put("expenses", expenses);
        res.put("usagePercentage", Math.min(usage, 200.0));
        return res;
    }

    public List<Map<String, Object>> getGoalProgress(String userId) {
        List<GoalDto> goals = goalService.getGoals(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (GoalDto g : goals) {
            Map<String, Object> m = new HashMap<>();
            double target = g.getTargetAmount() != null ? g.getTargetAmount() : 0.0;
            double saved = g.getSavedAmount() != null ? g.getSavedAmount() : 0.0;
            double pct = target > 0 ? Math.min((saved / target) * 100.0, 100.0) : 0.0;

            m.put("id", g.getId());
            m.put("name", g.getName());
            m.put("targetAmount", target);
            m.put("savedAmount", saved);
            m.put("targetDate", g.getTargetDate());
            m.put("category", g.getCategory());
            m.put("percentage", pct);
            result.add(m);
        }
        return result;
    }

    public List<Map<String, Object>> getUpcomingBills(String userId) {
        List<BillDto> bills = billService.getBills(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (BillDto b : bills) {
            if (!"Paid".equalsIgnoreCase(b.getStatus())) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", b.getId());
                m.put("name", b.getName());
                m.put("category", b.getCategory());
                m.put("amount", b.getAmount());
                m.put("dueDate", b.getDueDate());
                m.put("status", b.getStatus());
                result.add(m);
            }
        }
        return result;
    }

    public int getFinancialHealth(String userId) {
        double savingsRate = getSavingsRate(userId);
        Map<String, Object> budget = getBudgetStatus(userId);
        double targetBudget = (double) budget.get("targetBudget");
        double expenses = (double) budget.get("expenses");

        List<Map<String, Object>> goals = getGoalProgress(userId);
        double totalTarget = goals.stream().mapToDouble(g -> (double) g.get("targetAmount")).sum();
        double totalSaved = goals.stream().mapToDouble(g -> (double) g.get("savedAmount")).sum();
        double goalPct = totalTarget > 0 ? (totalSaved / totalTarget) * 100.0 : 0.0;

        double savingsScore = Math.min((savingsRate / 100.0) * 40.0, 40.0);
        double budgetRatio = expenses / (targetBudget > 0 ? targetBudget : 1.0);
        double budgetScore = Math.min(Math.max((1.0 - Math.min(budgetRatio, 1.0)) * 30.0, 0.0), 30.0);
        double goalScore = Math.min((goalPct / 100.0) * 30.0, 30.0);

        int healthScore = (int) Math.round(savingsScore + budgetScore + goalScore);
        return Math.min(Math.max(healthScore, 0), 100);
    }

    public Map<String, Object> buildUserFinancialContext(String userId, String prompt) {
        List<WalletDto> wallets = walletService.getWallets(userId);
        List<TransactionDto> transactions = transactionService.getTransactions(userId);
        List<GoalDto> goals = goalService.getGoals(userId);

        double balance = getCurrentBalance(userId);
        double income = getMonthlyIncome(userId);
        double expenses = getMonthlyExpenses(userId);
        double netCashFlow = income - expenses;
        double savingsRate = getSavingsRate(userId);
        int healthScore = getFinancialHealth(userId);

        Map<String, Object> budgetStatus = getBudgetStatus(userId);
        List<Map<String, Object>> goalProgress = getGoalProgress(userId);
        List<Map<String, Object>> upcomingBills = getUpcomingBills(userId);

        boolean hasData = (!wallets.isEmpty()) || (!transactions.isEmpty()) || (!goals.isEmpty()) || (income > 0);

        Map<String, Object> context = new HashMap<>();
        context.put("userId", userId);
        context.put("hasData", hasData);
        context.put("walletCount", wallets.size());
        context.put("currentBalance", balance);
        context.put("monthlyIncome", income);
        context.put("monthlyExpenses", expenses);
        context.put("netCashFlow", netCashFlow);
        context.put("savingsRate", savingsRate);
        context.put("healthScore", healthScore);
        context.put("targetBudget", budgetStatus.get("targetBudget"));
        context.put("budgetUsagePercentage", budgetStatus.get("usagePercentage"));
        context.put("categorySpending", getCategorySpending(userId));
        context.put("goals", goalProgress);
        context.put("upcomingBills", upcomingBills);
        context.put("recentTransactions", transactions.stream().limit(5).collect(Collectors.toList()));

        return context;
    }
}
