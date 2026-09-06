import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_ai_insight_card.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_empty_state.dart';
import '../../../auth_onboarding/presentation/providers/user_profile_provider.dart';
import '../../../budgets_savings/presentation/providers/goals_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// Stitch Screen: MoneyMateX Financial Health Analysis Screen
/// Entry Points: More → Financial Health OR AI Advisor → Financial Health
class AIHealthScorePage extends ConsumerStatefulWidget {
  const AIHealthScorePage({super.key});

  @override
  ConsumerState<AIHealthScorePage> createState() => _AIHealthScorePageState();
}

class _AIHealthScorePageState extends ConsumerState<AIHealthScorePage> {
  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final goals = ref.watch(goalsProvider);
    final userProfile = ref.watch(userProfileProvider);

    final expenseTransactions = transactions.where((t) => t.isExpense).toList();
    final incomeTransactions = transactions.where((t) => !t.isExpense).toList();

    final double totalExpenses = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double loggedIncome = incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double userIncome = userProfile.monthlyIncome;
    final double totalIncome = loggedIncome > 0 ? loggedIncome : userIncome;
    final double netSavings = totalIncome - totalExpenses;
    final double savingsRate = totalIncome > 0 ? (netSavings / totalIncome).clamp(0.0, 1.0) : 0.0;

    final double targetBudget = userProfile.monthlyExpensesEstimate > 0 ? userProfile.monthlyExpensesEstimate : 50000.0;
    final double budgetUsageRatio = targetBudget > 0 ? (totalExpenses / targetBudget).clamp(0.0, 1.5) : 0.0;

    final double totalSavedGoals = goals.fold<double>(0.0, (sum, g) => sum + g.savedAmount);
    final double totalTargetGoals = goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);
    final double goalProgressRatio = totalTargetGoals > 0 ? (totalSavedGoals / totalTargetGoals).clamp(0.0, 1.0) : 0.0;

    // Check if user has sufficient financial data
    final bool hasData = transactions.isNotEmpty || goals.isNotEmpty || totalIncome > 0;

    // Deterministic calculation of Financial Health Score (0-100)
    int healthScore = 0;
    if (hasData) {
      final savingsRateScore = (savingsRate * 40).clamp(0.0, 40.0);
      final budgetAdherenceScore = ((1.0 - budgetUsageRatio.clamp(0.0, 1.0)) * 30).clamp(0.0, 30.0);
      final goalScore = (goalProgressRatio * 30).clamp(0.0, 30.0);

      // Base minimum points for active management
      final basePoints = transactions.isNotEmpty ? 10.0 : 0.0;

      healthScore = (savingsRateScore + budgetAdherenceScore + goalScore + basePoints).round().clamp(0, 100);
    }

    String ratingLabel;
    Color scoreColor;
    Color scoreBgColor;

    if (healthScore >= 80) {
      ratingLabel = 'Excellent Financial Health';
      scoreColor = const Color(0xFF2E7D32);
      scoreBgColor = const Color(0xFFE8F5E9);
    } else if (healthScore >= 60) {
      ratingLabel = 'Good Financial Control';
      scoreColor = AppColors.primary;
      scoreBgColor = AppColors.primaryFixed;
    } else if (healthScore >= 40) {
      ratingLabel = 'Moderate Financial Health';
      scoreColor = Colors.amber.shade900;
      scoreBgColor = Colors.amber.shade100;
    } else {
      ratingLabel = 'Needs Attention';
      scoreColor = AppColors.error;
      scoreBgColor = const Color(0xFFFFEBEE);
    }

    // Dynamic Strengths
    final List<String> strengths = [];
    if (savingsRate >= 0.20) {
      strengths.add('Strong savings rate of ${(savingsRate * 100).toStringAsFixed(1)}% of total income');
    }
    if (budgetUsageRatio <= 0.80 && targetBudget > 0) {
      strengths.add('Disciplined spending under 80% of monthly budget');
    }
    if (goals.isNotEmpty && goalProgressRatio >= 0.25) {
      strengths.add('Active savings goal progress at ${(goalProgressRatio * 100).toStringAsFixed(1)}% portfolio completion');
    }
    if (strengths.isEmpty && hasData) {
      strengths.add('Regular transaction recording and financial tracking');
    }

    // Dynamic Areas for Improvement
    final List<String> improvements = [];
    if (savingsRate < 0.15 && totalIncome > 0) {
      improvements.add('Savings rate is below recommended 20% benchmark');
    }
    if (budgetUsageRatio > 1.0) {
      improvements.add('Monthly spending exceeds current budget target');
    }
    if (goals.isEmpty) {
      improvements.add('No active savings goals set for long-term targets');
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: Text(
          'Financial Health',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: !hasData
                  ? Column(
                      children: [
                        MMEmptyState(
                          icon: Icons.health_and_safety_outlined,
                          title: 'Financial Profile Incomplete',
                          subtitle: 'Complete your profile and log transactions to calculate your deterministic financial health score.',
                          actionLabel: '+ Add Income / Money',
                          onAction: () => context.go(AppRoutes.addMoney),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMButton(
                          label: '+ Create First Saving Goal',
                          onPressed: () => context.go(AppRoutes.smartPlanner),
                          type: MMButtonType.secondary,
                          fullWidth: true,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Health Score Hero Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'FINANCIAL HEALTH SCORE',
                                style: AppTypography.labelSmall.copyWith(letterSpacing: 1.0),
                              ),
                              const SizedBox(height: AppSpacing.m),

                              // Circular Score Gauge
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: CircularProgressIndicator(
                                      value: healthScore / 100,
                                      strokeWidth: 12,
                                      color: scoreColor,
                                      backgroundColor: AppColors.surfaceContainerHigh,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$healthScore',
                                        style: AppTypography.display.copyWith(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: scoreColor,
                                        ),
                                      ),
                                      Text(
                                        '/ 100',
                                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.m),

                              MMStatusChip(
                                label: ratingLabel,
                                backgroundColor: scoreBgColor,
                                textColor: scoreColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Score calculated deterministically from actual income, expenses, budget adherence, and goal progress.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Key Metrics Grid Cards
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _buildMetricCard('SAVINGS RATE', '${(savingsRate * 100).toStringAsFixed(0)}%', AppColors.primary),
                            _buildMetricCard('BUDGET USAGE', '${(budgetUsageRatio * 100).toStringAsFixed(0)}%', budgetUsageRatio <= 1 ? const Color(0xFF2E7D32) : AppColors.error),
                            _buildMetricCard('GOALS SAVED', '${(goalProgressRatio * 100).toStringAsFixed(0)}%', AppColors.tertiary),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Strengths Card
                        if (strengths.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.cardPadding),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Financial Strengths',
                                      style: AppTypography.headlineMedium.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.m),
                                ...strengths.map((s) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                        Expanded(child: Text(s, style: AppTypography.bodyMedium)),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.stackLg),
                        ],

                        // Areas for Improvement Card
                        if (improvements.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.cardPadding),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Areas for Improvement',
                                      style: AppTypography.headlineMedium.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.m),
                                ...improvements.map((imp) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                                        Expanded(child: Text(imp, style: AppTypography.bodyMedium)),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.stackLg),
                        ],

                        // AI Insights Banner
                        MMAIInsightCard(
                          title: 'MoneyMateX Financial Recommendations',
                          description: healthScore >= 80
                              ? 'Your financial indicators are in optimal standing! Keep making regular contributions to your active goals.'
                              : 'Increasing monthly savings by 5% and setting explicit category caps will boost your score above 80.',
                          actionLabel: 'View Goal Planner →',
                          onAction: () => context.go(AppRoutes.smartPlanner),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        Row(
                          children: [
                            Expanded(
                              child: MMPrimaryButton(
                                label: '+ Add Money',
                                onPressed: () => context.go(AppRoutes.addMoney),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: MMSecondaryButton(
                                label: 'Reports & Analytics',
                                onPressed: () => context.go(AppRoutes.reports),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.l),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.tagline.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias class for FinancialHealthPage
class FinancialHealthPage extends StatelessWidget {
  const FinancialHealthPage({super.key});
  @override
  Widget build(BuildContext context) => const AIHealthScorePage();
}
