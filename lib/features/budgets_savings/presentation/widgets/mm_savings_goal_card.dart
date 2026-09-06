import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_card.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_progress_bar.dart';

String _formatCurrency(num amount) {
  final str = amount.toStringAsFixed(0);
  final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$result';
}

/// Reusable Saving Goal Card component for MoneyMateX Budgets & Goals module
class MMSavingsGoalCard extends StatelessWidget {
  final String title;
  final String category;
  final double savedAmount;
  final double targetAmount;
  final String targetDate;
  final String status;
  final IconData icon;
  final Color categoryColor;
  final double? monthlyContribution;
  final bool isDetailedView;
  final VoidCallback? onTap;
  final VoidCallback? onContribute;

  const MMSavingsGoalCard({
    super.key,
    required this.title,
    required this.category,
    required this.savedAmount,
    required this.targetAmount,
    required this.targetDate,
    required this.status,
    required this.icon,
    this.categoryColor = AppColors.primary,
    this.monthlyContribution,
    this.isDetailedView = false,
    this.onTap,
    this.onContribute,
  });

  Color _getStatusBgColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.tertiaryFixed;
      case 'on track':
      case 'near goal':
        return AppColors.primaryFixed;
      case 'at risk':
      case 'behind':
        return AppColors.errorContainer;
      default:
        return AppColors.secondaryContainer;
    }
  }

  Color _getStatusTextColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.onTertiaryContainer;
      case 'on track':
      case 'near goal':
        return AppColors.onPrimaryFixedVariant;
      case 'at risk':
      case 'behind':
        return AppColors.onErrorContainer;
      default:
        return AppColors.onSecondaryContainer;
    }
  }

  Color _getProgressColor() {
    final ratio = targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    if (ratio >= 1.0) return AppColors.tertiaryContainer;
    if (status.toLowerCase().contains('risk') || status.toLowerCase().contains('behind')) {
      return AppColors.error;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final progress = targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);
    final remainingAmount = (targetAmount - savedAmount).clamp(0.0, double.infinity);

    return MMCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Icon(icon, color: categoryColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.headlineMedium.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        MMStatusChip(
                          label: status,
                          backgroundColor: _getStatusBgColor(),
                          textColor: _getStatusTextColor(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$category • Target: $targetDate',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),

          // Amounts row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved',
                    style: AppTypography.labelSmall.copyWith(fontSize: 11),
                  ),
                  Text(
                    _formatCurrency(savedAmount),
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Target ($percentage%)',
                    style: AppTypography.labelSmall.copyWith(fontSize: 11),
                  ),
                  Text(
                    _formatCurrency(targetAmount),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),

          // Progress bar
          MMProgressBar(
            progress: progress,
            color: _getProgressColor(),
            height: 8,
          ),

          if (isDetailedView) ...[
            const SizedBox(height: AppSpacing.m),
            const Divider(height: 1, color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Remaining: ${_formatCurrency(remainingAmount)}',
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
                if (monthlyContribution != null)
                  Text(
                    '${_formatCurrency(monthlyContribution!)}/mo',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ],

          if (onContribute != null && progress < 1.0) ...[
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton.icon(
                onPressed: onContribute,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('+ Add Contribution'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  textStyle: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
