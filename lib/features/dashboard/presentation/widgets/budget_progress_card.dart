import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import 'circular_budget_painter.dart';

/// Dedicated Budget Card with Animated Circular Progress Indicator
class BudgetProgressCard extends StatelessWidget {
  final double budgetLimit;
  final double totalSpent;
  final int daysLeft;
  final VoidCallback onViewBudget;

  const BudgetProgressCard({
    super.key,
    required this.budgetLimit,
    required this.totalSpent,
    this.daysLeft = 12,
    required this.onViewBudget,
  });

  String _formatCurrency(double amount) {
    return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final double remaining = (budgetLimit - totalSpent).clamp(0.0, budgetLimit);
    final double usedProgress =
        budgetLimit > 0 ? (totalSpent / budgetLimit).clamp(0.0, 1.0) : 0.0;
    final int usedPercent = (usedProgress * 100).round();
    final int remainingPercent = 100 - usedPercent;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Center Circular Ring
          Center(
            child: CircularBudgetRing(
              progress: usedProgress,
              percentageText: '$remainingPercent%',
              remainingAmountText: '${_formatCurrency(remaining)} left',
              size: 130,
            ),
          ),

          const SizedBox(height: AppSpacing.m),

          // Remaining Text & Days Left Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatCurrency(remaining)} remaining',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${_formatCurrency(totalSpent)} of ${_formatCurrency(budgetLimit)} used',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$daysLeft days left',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // CTA Button
          MMSecondaryButton(
            label: 'View Budget',
            onPressed: onViewBudget,
          ),
        ],
      ),
    );
  }
}
