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

/// Screen 6 — Money Health Page
class MoneyHealthPage extends ConsumerWidget {
  const MoneyHealthPage({super.key});

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
          'Money Health',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time automated financial health assessment and smart recommendations.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            if (!summary.hasData) ...[
              // Authentic Empty State for Fresh Users (ZERO fake score!)
              MMEmptyState(
                icon: Icons.health_and_safety_outlined,
                title: 'Build Your Financial History',
                subtitle: 'Add income and expenses to unlock your Money Health score and AI insights.',
                actionLabel: 'Add Transaction',
                onAction: () => context.push(AppRoutes.addExpense),
              ),

              const SizedBox(height: AppSpacing.l),

              // Placeholder info card explaining metrics
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
                    Text(
                      'What affects your Money Health?',
                      style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildHealthMetricExplanation('Net Cash Flow', 'Positive income after expenses improves your score.'),
                    const Divider(color: AppColors.outlineVariant),
                    _buildHealthMetricExplanation('Savings Rate', 'Saving >20% of your income boosts your resilience.'),
                    const Divider(color: AppColors.outlineVariant),
                    _buildHealthMetricExplanation('Budget Utilization', 'Keeping spending within budget protects net worth.'),
                  ],
                ),
              ),
            ] else ...[
              // Real Financial Health Score Card (Derived mathematically from summary!)
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MONEY HEALTH SCORE',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 0.8),
                        ),
                        MMStatusChip(
                          label: summary.healthScore >= 75 ? 'Healthy' : (summary.healthScore >= 50 ? 'Moderate' : 'Needs Attention'),
                          backgroundColor: summary.healthScore >= 75 ? const Color(0xFFD1FAE5) : AppColors.tertiaryContainer,
                          textColor: summary.healthScore >= 75 ? const Color(0xFF065F46) : AppColors.onTertiaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: (summary.healthScore / 100).clamp(0.0, 1.0),
                            strokeWidth: 12,
                            backgroundColor: AppColors.surfaceContainerLow,
                            color: summary.healthScore >= 75 ? const Color(0xFF10B981) : AppColors.primary,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${summary.healthScore}',
                              style: AppTypography.display.copyWith(fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'out of 100',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.l),
                    const Divider(color: AppColors.outlineVariant),
                    const SizedBox(height: AppSpacing.m),

                    _buildHealthScoreRow('Savings Rate', '${summary.savingsRate.toStringAsFixed(1)}%', (summary.savingsRate / 100).clamp(0.0, 1.0)),
                    const SizedBox(height: AppSpacing.m),
                    _buildHealthScoreRow('Budget Utilization', '${summary.budgetUsagePercentage.toStringAsFixed(1)}%', (summary.budgetUsagePercentage / 100).clamp(0.0, 1.0)),
                    const SizedBox(height: AppSpacing.m),
                    _buildHealthScoreRow('Savings Goals Overall', '${summary.goalProgressPercentage.toStringAsFixed(1)}%', (summary.goalProgressPercentage / 100).clamp(0.0, 1.0)),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.stackLg),

              // Dynamic Insights based on real data
              Text(
                'Personalized Financial Insights',
                style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),

              if (summary.totalExpenses > summary.totalIncome) ...[
                _buildInsightCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'High Expense Ratio',
                  desc: 'Your expenses are currently higher than your income. Review recurring subscriptions and dining out.',
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              if (summary.savingsRate > 20) ...[
                _buildInsightCard(
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Strong Savings Rate',
                  desc: 'Your current savings rate is strong at ${summary.savingsRate.toStringAsFixed(1)}%. Consider routing surplus to your savings goals.',
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              if (summary.budgetUsagePercentage > 85) ...[
                _buildInsightCard(
                  icon: Icons.pie_chart_outline,
                  title: 'Near Budget Limit',
                  desc: 'You are close to your monthly budget limit (${summary.budgetUsagePercentage.toStringAsFixed(1)}%).',
                  color: AppColors.tertiary,
                ),
                const SizedBox(height: AppSpacing.m),
              ],
            ],

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: 'Add Transaction',
              icon: Icons.add,
              onPressed: () => context.push(AppRoutes.addExpense),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricExplanation(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(desc, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildHealthScoreRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium),
            Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        MMProgressBar(progress: progress),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
