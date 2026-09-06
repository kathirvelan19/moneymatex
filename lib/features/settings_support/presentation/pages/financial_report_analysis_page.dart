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
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_empty_state.dart';
import '../../../../core/widgets/mm_progress_bar.dart';

/// Screen 7 — Reports & Analytics Page
class FinancialReportAnalysisPage extends ConsumerStatefulWidget {
  const FinancialReportAnalysisPage({super.key});

  @override
  ConsumerState<FinancialReportAnalysisPage> createState() => _FinancialReportAnalysisPageState();
}

class _FinancialReportAnalysisPageState extends ConsumerState<FinancialReportAnalysisPage> {
  String _selectedPeriod = 'This Month'; // 'This Week', 'This Month', 'Last Month', '3 Months'

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(financialAnalyticsProvider);
    final summary = analytics.computeSummary();

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
          'Financial Report',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time spending analysis and automated financial health report.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            // Time Period Filters (This Week, This Month, Last Month, 3 Months)
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

            if (!summary.hasData) ...[
              // Authentic Empty State for Fresh Users (ZERO fake chart/sample values!)
              MMEmptyState(
                icon: Icons.analytics_outlined,
                title: 'Not Enough Transaction History',
                subtitle: 'Add your first wallet account or log a transaction to generate your personal spending report.',
                actionLabel: 'Add Wallet Account',
                onAction: () => context.push(AppRoutes.addWalletSelection),
              ),

              const SizedBox(height: AppSpacing.l),

              // Zero summary placeholders
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    _buildSummaryMetric('Total Income', '₹0', Colors.green),
                    const Divider(color: AppColors.outlineVariant),
                    _buildSummaryMetric('Total Expenses', '₹0', AppColors.primary),
                    const Divider(color: AppColors.outlineVariant),
                    _buildSummaryMetric('Net Cash Flow', '₹0', AppColors.onBackground),
                    const Divider(color: AppColors.outlineVariant),
                    _buildSummaryMetric('Savings Rate', '0.0%', AppColors.secondary),
                  ],
                ),
              ),
            ] else ...[
              // Financial Summary Card with REAL calculated values from FinancialAnalyticsService
              Container(
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
                          'FINANCIAL SUMMARY ($_selectedPeriod)',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        MMStatusChip(
                          label: 'Score ${summary.healthScore}/100',
                          backgroundColor: AppColors.primaryContainer,
                          textColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildSummaryMetric(
                      'Total Income',
                      '₹${summary.totalIncome.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      const Color(0xFF10B981),
                    ),
                    const Divider(color: AppColors.outlineVariant),
                    _buildSummaryMetric(
                      'Total Expenses',
                      '₹${summary.totalExpenses.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      AppColors.primary,
                    ),
                    const Divider(color: AppColors.outlineVariant),
                    _buildSummaryMetric(
                      'Net Cash Flow',
                      '₹${summary.netCashFlow.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      summary.netCashFlow >= 0 ? const Color(0xFF10B981) : AppColors.error,
                    ),
                    const Divider(color: AppColors.outlineVariant),
                    _buildSummaryMetric(
                      'Savings Rate',
                      '${summary.savingsRate.toStringAsFixed(1)}%',
                      AppColors.secondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.stackLg),

              // Category Spending Breakdown
              Text(
                'Spending Breakdown by Category',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),

              if (summary.categoryExpenses.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                  ),
                  child: Text(
                    'No expenses recorded in this period.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: summary.categoryExpenses.entries.map((entry) {
                      final pct = summary.totalExpenses > 0 ? (entry.value / summary.totalExpenses) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
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

              // Budget & Goal Progress Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget & Goal Progress',
                      style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budget Used', style: AppTypography.bodyMedium),
                        Text(
                          '${summary.budgetUsagePercentage.toStringAsFixed(1)}%',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    MMProgressBar(
                      progress: (summary.budgetUsagePercentage / 100).clamp(0.0, 1.0),
                      color: summary.budgetUsagePercentage > 90 ? AppColors.error : AppColors.primary,
                    ),

                    const SizedBox(height: AppSpacing.m),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saving Goals Overall Progress', style: AppTypography.bodyMedium),
                        Text(
                          '${summary.goalProgressPercentage.toStringAsFixed(1)}%',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    MMProgressBar(
                      progress: (summary.goalProgressPercentage / 100).clamp(0.0, 1.0),
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.stackLg),

              // Insights & Recommendations
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'AI Financial Insight',
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary.savingsRate > 20
                          ? 'Great job! Your savings rate is healthy at ${summary.savingsRate.toStringAsFixed(1)}%. Consider allocating surplus cash to active saving goals.'
                          : 'Your savings rate is ${summary.savingsRate.toStringAsFixed(1)}%. Track discretionary dining & shopping expenses to boost your monthly net savings.',
                      style: AppTypography.labelSmall.copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: 'Scan New Receipt',
              icon: Icons.camera_alt,
              onPressed: () => context.push(AppRoutes.scanReceipt),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceVariant)),
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
