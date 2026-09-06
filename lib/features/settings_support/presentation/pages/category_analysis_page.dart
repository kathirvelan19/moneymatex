import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/financial_analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_empty_state.dart';

import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// Stitch Batch — Category Analysis & Trends Page
class CategoryAnalysisPage extends ConsumerStatefulWidget {
  const CategoryAnalysisPage({super.key});

  @override
  ConsumerState<CategoryAnalysisPage> createState() => _CategoryAnalysisPageState();
}

class _CategoryAnalysisPageState extends ConsumerState<CategoryAnalysisPage> {
  String _selectedPeriod = 'This Month'; // 'This Week', 'This Month', 'Last Month', '3 Months'

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(financialAnalyticsProvider);
    final summary = analytics.computeSummary();
    final transactions = ref.watch(transactionsProvider);

    final expenseTransactions = transactions.where((t) => t.isExpense).toList();
    final totalExpenses = summary.totalExpenses;

    final sortedCategories = summary.categoryExpenses.entries.toList()
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
          'Category Analysis',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed expense breakdown and category spending percentages.',
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

            if (sortedCategories.isEmpty) ...[
              MMEmptyState(
                icon: Icons.category_outlined,
                title: 'No Category Data Yet',
                subtitle: 'Add expense transactions to categorize your spending and analyze top expense areas.',
                actionLabel: '+ Add Expense',
                onAction: () => context.push(AppRoutes.addExpense),
              ),
            ] else ...[
              // Summary Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACTIVE CATEGORIES', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                        const SizedBox(height: 4),
                        Text('${sortedCategories.length} Categories', style: AppTypography.headlineLarge.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('TOTAL EXPENSES', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalExpenses.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: AppTypography.headlineLarge.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.stackLg),

              // Categories List Card
              Text(
                'Category Spending Distribution',
                style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),

              ...sortedCategories.map((entry) {
                final catName = entry.key;
                final catAmount = entry.value;
                final pct = totalExpenses > 0 ? (catAmount / totalExpenses) : 0.0;
                final categoryTxns = expenseTransactions.where((t) => t.category == catName).toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.m),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(AppRadius.m),
                                ),
                                child: Icon(
                                  TransactionsNotifier.getCategoryIcon(catName),
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(catName, style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('${categoryTxns.length} Transactions', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹${catAmount.toInt()}', style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('${(pct * 100).toStringAsFixed(1)}%', style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                      MMProgressBar(progress: pct.clamp(0.0, 1.0)),
                    ],
                  ),
                );
              }),
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
