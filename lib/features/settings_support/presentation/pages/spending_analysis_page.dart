import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_empty_state.dart';
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// Stitch Batch — Spending Analysis Page
class SpendingAnalysisPage extends ConsumerStatefulWidget {
  const SpendingAnalysisPage({super.key});

  @override
  ConsumerState<SpendingAnalysisPage> createState() => _SpendingAnalysisPageState();
}

class _SpendingAnalysisPageState extends ConsumerState<SpendingAnalysisPage> {
  String _selectedPeriod = 'This Month'; // 'This Week', 'This Month', 'Last Month', '3 Months'

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    final now = DateTime.now();
    final expenseTransactions = transactions.where((t) {
      if (!t.isExpense) return false;
      switch (_selectedPeriod) {
        case 'This Week':
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          return t.date.isAfter(sevenDaysAgo);
        case 'This Month':
          return t.date.year == now.year && t.date.month == now.month;
        case 'Last Month':
          final lastMonthDate = DateTime(now.year, now.month - 1, 1);
          return t.date.year == lastMonthDate.year && t.date.month == lastMonthDate.month;
        case '3 Months':
          final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
          return t.date.isAfter(threeMonthsAgo);
        default:
          return true;
      }
    }).toList();

    final double totalSpending = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);

    final Map<String, double> categorySpending = {};
    for (final t in expenseTransactions) {
      categorySpending[t.category] = (categorySpending[t.category] ?? 0.0) + t.amount;
    }

    final sortedCategoryExpenses = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          'Spending Analysis',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed expense distribution and category spending trends.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            // Time Period Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['This Week', 'This Month', 'Last Month', '3 Months'].map((period) {
                  final sel = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: sel,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: sel ? AppColors.primary : AppColors.onSurface,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedPeriod = period);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            if (expenseTransactions.isEmpty) ...[
              MMEmptyState(
                icon: Icons.pie_chart_outline,
                title: 'No Expense Transactions Logged',
                subtitle: 'No expenses recorded for $_selectedPeriod. Log your purchases to start building your spending analysis.',
                actionLabel: '+ Add Expense',
                onAction: () => context.push(AppRoutes.addExpense),
              ),
            ] else ...[
              // Total Spending Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL SPENDING ($_selectedPeriod)',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        MMStatusChip(
                          label: '${expenseTransactions.length} Transactions',
                          backgroundColor: AppColors.primaryContainer,
                          textColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      '₹${totalSpending.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: AppTypography.display.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.stackLg),

              // Category Distribution
              Text(
                'Spending by Category',
                style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),

              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: sortedCategoryExpenses.map((entry) {
                    final pct = totalSpending > 0 ? (entry.value / totalSpending) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${entry.value.toInt()} (${(pct * 100).toStringAsFixed(1)}%)',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          MMProgressBar(progress: pct.clamp(0.0, 1.0)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: '+ Add Expense',
              icon: Icons.add,
              onPressed: () => context.push(AppRoutes.addExpense),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
