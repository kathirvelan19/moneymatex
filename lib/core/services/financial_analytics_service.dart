import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/accounts/presentation/providers/user_wallets_provider.dart';
import '../../features/auth_onboarding/presentation/providers/user_profile_provider.dart';
import '../../features/budgets_savings/presentation/providers/goals_provider.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';

/// Central Domain Summary Model for authenticated user's financial state
class UserFinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double netCashFlow;
  final double savingsRate;
  final double totalWalletBalance;
  final double totalGoalSaved;
  final double totalGoalTarget;
  final double goalProgressPercentage;
  final double targetBudget;
  final double budgetUsagePercentage;
  final int healthScore;
  final Map<String, double> categoryExpenses;
  final Map<String, double> categoryIncome;
  final bool hasData;

  const UserFinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.savingsRate,
    required this.totalWalletBalance,
    required this.totalGoalSaved,
    required this.totalGoalTarget,
    required this.goalProgressPercentage,
    required this.targetBudget,
    required this.budgetUsagePercentage,
    required this.healthScore,
    required this.categoryExpenses,
    required this.categoryIncome,
    required this.hasData,
  });
}

/// Central Domain Service for MoneyMateX Financial Calculations & AI Context Generation
class FinancialAnalyticsService {
  final List<TransactionItem> transactions;
  final List<GoalItem> goals;
  final List<WalletItem> wallets;
  final UserProfileState profile;

  FinancialAnalyticsService({
    required this.transactions,
    required this.goals,
    required this.wallets,
    required this.profile,
  });

  UserFinancialSummary computeSummary() {
    final expenseTransactions = transactions.where((t) => t.isExpense).toList();
    final incomeTransactions = transactions.where((t) => !t.isExpense).toList();

    final double totalExpenses = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double loggedIncome = incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double userIncome = profile.monthlyIncome > 0 ? profile.monthlyIncome : 0.0;
    final double totalIncome = loggedIncome > 0 ? loggedIncome : userIncome;
    final double netCashFlow = totalIncome - totalExpenses;
    final double savingsRate = totalIncome > 0 ? ((netCashFlow / totalIncome) * 100).clamp(0.0, 100.0) : 0.0;

    final double totalWalletBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);

    final double totalGoalSaved = goals.fold(0.0, (sum, g) => sum + g.savedAmount);
    final double totalGoalTarget = goals.fold(0.0, (sum, g) => sum + g.targetAmount);
    final double goalProgressPercentage = totalGoalTarget > 0 ? ((totalGoalSaved / totalGoalTarget) * 100).clamp(0.0, 100.0) : 0.0;

    final double targetBudget = profile.monthlyExpensesEstimate > 0 ? profile.monthlyExpensesEstimate : 50000.0;
    final double budgetUsagePercentage = targetBudget > 0 ? ((totalExpenses / targetBudget) * 100).clamp(0.0, 200.0) : 0.0;

    final Map<String, double> categoryExpenses = {};
    for (final t in expenseTransactions) {
      categoryExpenses[t.category] = (categoryExpenses[t.category] ?? 0.0) + t.amount;
    }

    final Map<String, double> categoryIncome = {};
    for (final t in incomeTransactions) {
      categoryIncome[t.category] = (categoryIncome[t.category] ?? 0.0) + t.amount;
    }

    final bool hasData = transactions.isNotEmpty || goals.isNotEmpty || wallets.isNotEmpty || profile.monthlyIncome > 0;

    int healthScore = 0;
    if (hasData) {
      final savingsScore = (savingsRate / 100 * 40).clamp(0.0, 40.0);
      final budgetScore = ((1.0 - (totalExpenses / targetBudget).clamp(0.0, 1.0)) * 30).clamp(0.0, 30.0);
      final goalScore = (goalProgressPercentage / 100 * 30).clamp(0.0, 30.0);
      healthScore = (savingsScore + budgetScore + goalScore).round().clamp(0, 100);
    }

    return UserFinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netCashFlow: netCashFlow,
      savingsRate: savingsRate,
      totalWalletBalance: totalWalletBalance,
      totalGoalSaved: totalGoalSaved,
      totalGoalTarget: totalGoalTarget,
      goalProgressPercentage: goalProgressPercentage,
      targetBudget: targetBudget,
      budgetUsagePercentage: budgetUsagePercentage,
      healthScore: healthScore,
      categoryExpenses: categoryExpenses,
      categoryIncome: categoryIncome,
      hasData: hasData,
    );
  }

  // Explicit Deterministic Financial Tool Helpers
  double getCurrentBalance() => computeSummary().totalWalletBalance;
  double getMonthlyIncome() => computeSummary().totalIncome;
  double getMonthlyExpenses() => computeSummary().totalExpenses;
  double getNetCashFlow() => computeSummary().netCashFlow;
  double getSavingsRate() => computeSummary().savingsRate;
  Map<String, double> getCategorySpending() => computeSummary().categoryExpenses;
  double getBudgetStatus() => computeSummary().budgetUsagePercentage;
  double getGoalProgress() => computeSummary().goalProgressPercentage;
  int getFinancialHealth() => computeSummary().healthScore;
  List<TransactionItem> getRecentTransactions() => transactions.take(10).toList();

  String getWeeklySummary() {
    final s = computeSummary();
    return "Weekly Summary: Income ₹${s.totalIncome.toInt()}, Expenses ₹${s.totalExpenses.toInt()}, Net Cash Flow ₹${s.netCashFlow.toInt()}, Savings Rate ${s.savingsRate.toStringAsFixed(1)}%.";
  }

  /// Generate structured context text for K2i AI Chatbot
  String buildK2iFinancialContextPrompt() {
    final summary = computeSummary();
    if (!summary.hasData) {
      return "AUTHENTICATED USER FINANCIAL CONTEXT:\n- Status: Fresh user with no recorded transactions, goals, or wallet balances yet.";
    }

    final buffer = StringBuffer();
    buffer.writeln("AUTHENTICATED USER REAL FINANCIAL CONTEXT:");
    buffer.writeln("- User Name: ${profile.name}");
    buffer.writeln("- Total Wallet Balance: ₹${summary.totalWalletBalance.toInt()} across ${wallets.length} accounts");
    buffer.writeln("- Total Income: ₹${summary.totalIncome.toInt()}");
    buffer.writeln("- Total Expenses: ₹${summary.totalExpenses.toInt()}");
    buffer.writeln("- Net Cash Flow: ₹${summary.netCashFlow.toInt()}");
    buffer.writeln("- Savings Rate: ${summary.savingsRate.toStringAsFixed(1)}%");
    buffer.writeln("- Budget Target: ₹${summary.targetBudget.toInt()} (Usage: ${summary.budgetUsagePercentage.toStringAsFixed(1)}%)");
    buffer.writeln("- Financial Health Score: ${summary.healthScore}/100");

    if (goals.isNotEmpty) {
      buffer.writeln("- Active Saving Goals (${goals.length}):");
      for (final g in goals) {
        final pct = g.targetAmount > 0 ? (g.savedAmount / g.targetAmount * 100).toStringAsFixed(1) : '0';
        buffer.writeln("  * ${g.name} (${g.category}): Saved ₹${g.savedAmount.toInt()} of ₹${g.targetAmount.toInt()} ($pct%) by ${g.targetDate.toString().split(' ')[0]}");
      }
    } else {
      buffer.writeln("- Active Saving Goals: None created yet.");
    }

    if (summary.categoryExpenses.isNotEmpty) {
      buffer.writeln("- Top Expense Categories:");
      final sorted = summary.categoryExpenses.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sorted.take(5)) {
        buffer.writeln("  * ${entry.key}: ₹${entry.value.toInt()}");
      }
    }

    return buffer.toString();
  }
}

/// Provider for FinancialAnalyticsService
final financialAnalyticsProvider = Provider<FinancialAnalyticsService>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final goals = ref.watch(goalsProvider);
  final wallets = ref.watch(userWalletsProvider);
  final profile = ref.watch(userProfileProvider);

  return FinancialAnalyticsService(
    transactions: transactions,
    goals: goals,
    wallets: wallets,
    profile: profile,
  );
});
