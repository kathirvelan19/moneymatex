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
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

String _formatCurrency(num amount) {
  final str = amount.toStringAsFixed(0);
  final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$result';
}

/// Stitch Screen: MoneyMateX Weekly Briefing & AI Financial Summary Screen
/// Entry Point: More → Weekly Briefing
class WeeklyBriefingPage extends ConsumerStatefulWidget {
  const WeeklyBriefingPage({super.key});

  @override
  ConsumerState<WeeklyBriefingPage> createState() => _WeeklyBriefingPageState();
}

class _WeeklyBriefingPageState extends ConsumerState<WeeklyBriefingPage> {
  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    // Filter transactions for Current Week (past 7 days)
    final currentWeekTransactions = transactions.where((t) => t.date.isAfter(sevenDaysAgo)).toList();

    // Filter transactions for Previous Week (days 7 to 14)
    final prevWeekTransactions = transactions.where((t) => t.date.isAfter(fourteenDaysAgo) && t.date.isBefore(sevenDaysAgo)).toList();

    final currentWeekExpensesList = currentWeekTransactions.where((t) => t.isExpense).toList();
    final currentWeekIncomeList = currentWeekTransactions.where((t) => !t.isExpense).toList();

    final double currentWeekExpenses = currentWeekExpensesList.fold(0.0, (sum, t) => sum + t.amount);
    final double currentWeekIncome = currentWeekIncomeList.fold(0.0, (sum, t) => sum + t.amount);
    final double currentWeekSavings = currentWeekIncome - currentWeekExpenses;

    final double prevWeekExpenses = prevWeekTransactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

    // Expense change % vs previous week
    double expChangePercent = 0.0;
    if (prevWeekExpenses > 0) {
      expChangePercent = ((currentWeekExpenses - prevWeekExpenses) / prevWeekExpenses * 100);
    }

    // Top Category this week
    final Map<String, double> categoryTotals = {};
    for (final t in currentWeekExpensesList) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0.0) + t.amount;
    }

    MapEntry<String, double>? topCategory;
    if (categoryTotals.isNotEmpty) {
      topCategory = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
    }

    // Largest single transaction this week
    TransactionItem? largestTransaction;
    if (currentWeekExpensesList.isNotEmpty) {
      largestTransaction = currentWeekExpensesList.reduce((a, b) => a.amount > b.amount ? a : b);
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
          'Weekly Briefing',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline, color: AppColors.primary),
            tooltip: 'View Reports',
            onPressed: () => context.go(AppRoutes.reports),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
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
              child: currentWeekTransactions.isEmpty
                  ? Column(
                      children: [
                        MMEmptyState(
                          icon: Icons.calendar_view_week_outlined,
                          title: 'Not Enough Activity This Week',
                          subtitle: 'No transactions recorded in the past 7 days. Log expenses or add income to generate your weekly financial briefing.',
                          actionLabel: '+ Add Expense',
                          onAction: () => context.go(AppRoutes.addExpense),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMButton(
                          label: '+ Deposit Income / Money',
                          onPressed: () => context.go(AppRoutes.addMoney),
                          type: MMButtonType.secondary,
                          fullWidth: true,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly AI Briefing',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Summary of spending trends, largest transactions, and behavior insights for the past 7 days.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.stackLg),

                        // Weekly Cash Flow Hero Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('THIS WEEK\'S CASH FLOW', style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8)),
                                  MMStatusChip(
                                    label: expChangePercent <= 0 ? 'Spending Down' : 'Spending Up',
                                    backgroundColor: expChangePercent <= 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                    textColor: expChangePercent <= 0 ? const Color(0xFF2E7D32) : AppColors.error,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s),
                              Text(
                                _formatCurrency(currentWeekExpenses),
                                style: AppTypography.display.copyWith(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Weekly Expenses across ${currentWeekExpensesList.length} transactions',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: AppSpacing.m),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text('Weekly Income', style: AppTypography.labelSmall),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatCurrency(currentWeekIncome),
                                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                      ),
                                    ],
                                  ),
                                  Container(width: 1, height: 28, color: AppColors.outlineVariant),
                                  Column(
                                    children: [
                                      Text('Net Weekly Savings', style: AppTypography.labelSmall),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatCurrency(currentWeekSavings),
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: currentWeekSavings >= 0 ? const Color(0xFF2E7D32) : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Spending Trend Comparison Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SPENDING COMPARISON VS LAST WEEK', style: AppTypography.labelSmall),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    expChangePercent <= 0 ? Icons.trending_down : Icons.trending_up,
                                    color: expChangePercent <= 0 ? const Color(0xFF2E7D32) : AppColors.error,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${expChangePercent.abs().toStringAsFixed(1)}% ${expChangePercent <= 0 ? 'Decrease' : 'Increase'}',
                                    style: AppTypography.headlineMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: expChangePercent <= 0 ? const Color(0xFF2E7D32) : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Current week spending: ${_formatCurrency(currentWeekExpenses)} vs Previous week: ${_formatCurrency(prevWeekExpenses)}',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Top Category & Largest Transaction
                        Row(
                          children: [
                            if (topCategory != null)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(AppRadius.xl),
                                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('TOP CATEGORY THIS WEEK', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                                      const SizedBox(height: 4),
                                      Text(
                                        topCategory.key,
                                        style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _formatCurrency(topCategory.value),
                                        style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (topCategory != null && largestTransaction != null)
                              const SizedBox(width: AppSpacing.s),
                            if (largestTransaction != null)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(AppRadius.xl),
                                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('LARGEST SINGLE SPEND', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                                      const SizedBox(height: 4),
                                      Text(
                                        largestTransaction.title,
                                        style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _formatCurrency(largestTransaction.amount),
                                        style: AppTypography.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // MoneyMateX AI Weekly Insight
                        MMAIInsightCard(
                          title: 'MoneyMateX Weekly Recommendation',
                          description: expChangePercent <= 0
                              ? 'Great job keeping spending down this week! You saved ${_formatCurrency(currentWeekSavings)}.'
                              : 'Spending increased by ${expChangePercent.toStringAsFixed(1)}% this week, primarily in ${topCategory?.key ?? 'recent expenses'}. Review category caps.',
                          actionLabel: 'View Detailed Reports →',
                          onAction: () => context.go(AppRoutes.reports),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        Row(
                          children: [
                            Expanded(
                              child: MMPrimaryButton(
                                label: '+ Add Expense',
                                onPressed: () => context.go(AppRoutes.addExpense),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: MMSecondaryButton(
                                label: '+ Deposit Money',
                                onPressed: () => context.go(AppRoutes.addMoney),
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
}
