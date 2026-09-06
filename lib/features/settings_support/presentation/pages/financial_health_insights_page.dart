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


/// Stitch Batch — Financial Health Insights & Recommendations Page
class FinancialHealthInsightsPage extends ConsumerWidget {
  const FinancialHealthInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Health Insights & Recommendations',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized smart recommendations generated from your financial activity.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            if (!summary.hasData) ...[
              MMEmptyState(
                icon: Icons.lightbulb_outline,
                title: 'Need More Financial Activity',
                subtitle: 'Add income and log transactions to generate personalized insights and AI recommendations.',
                actionLabel: '+ Add Expense',
                onAction: () => context.push(AppRoutes.addExpense),
              ),
            ] else ...[
              // Summary Score Badge
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        'Money Health Score: ${summary.healthScore}/100 based on net savings, budget usage, and goal progress.',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.stackLg),

              Text(
                'Actionable Insights',
                style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),

              if (summary.totalExpenses > summary.totalIncome) ...[
                _buildRecommendationTile(
                  title: 'Expenses Exceed Income',
                  subtitle: 'Your expenses (₹${summary.totalExpenses.toInt()}) exceed total income (₹${summary.totalIncome.toInt()}).',
                  actionText: 'Review Spending →',
                  icon: Icons.error_outline,
                  color: AppColors.error,
                  onTap: () => context.push(AppRoutes.spendingAnalysis),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              if (summary.savingsRate > 20) ...[
                _buildRecommendationTile(
                  title: 'Healthy Savings Rate',
                  subtitle: 'Your savings rate is ${summary.savingsRate.toStringAsFixed(1)}%. Consider allocating surplus capital to active goals.',
                  actionText: 'Manage Goals →',
                  icon: Icons.savings_outlined,
                  color: const Color(0xFF10B981),
                  onTap: () => context.push(AppRoutes.goals),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              if (summary.budgetUsagePercentage > 85) ...[
                _buildRecommendationTile(
                  title: 'Budget Limit Approaching',
                  subtitle: 'You have used ${summary.budgetUsagePercentage.toStringAsFixed(1)}% of your monthly target budget.',
                  actionText: 'View Budgets →',
                  icon: Icons.pie_chart_outline,
                  color: AppColors.tertiary,
                  onTap: () => context.push(AppRoutes.budgetPerformance),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              if (summary.categoryExpenses.isNotEmpty) ...[
                _buildRecommendationTile(
                  title: 'Top Expense Category Alert',
                  subtitle: 'Your largest expense category is "${summary.categoryExpenses.entries.reduce((a, b) => a.value > b.value ? a : b).key}".',
                  actionText: 'Analyze Categories →',
                  icon: Icons.category_outlined,
                  color: AppColors.primary,
                  onTap: () => context.push(AppRoutes.categoryAnalysis),
                ),
              ],
            ],

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: 'View Detailed Financial Report',
              onPressed: () => context.push(AppRoutes.financialAnalysis),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile({
    required String title,
    required String subtitle,
    required String actionText,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
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
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.m),
          InkWell(
            onTap: onTap,
            child: Text(
              actionText,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
