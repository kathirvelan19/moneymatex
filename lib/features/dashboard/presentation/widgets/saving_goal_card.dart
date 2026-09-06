import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_progress_bar.dart';

/// Saving Goal Card driven 100% by user's profile and goals data
class SavingGoalCard extends StatelessWidget {
  final String goalTitle;
  final String targetDate;
  final double currentSaved;
  final double targetAmount;
  final VoidCallback onViewGoal;

  const SavingGoalCard({
    super.key,
    required this.goalTitle,
    required this.targetDate,
    required this.currentSaved,
    required this.targetAmount,
    required this.onViewGoal,
  });

  String _formatCurrency(double amount) {
    return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        targetAmount > 0 ? (currentSaved / targetAmount).clamp(0.0, 1.0) : 0.0;
    final int percentInt = (progress * 100).round();
    final bool hasTarget = targetAmount > 0;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Saving Goal',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    goalTitle.isNotEmpty
                        ? '$goalTitle${targetDate.isNotEmpty ? " • Target: $targetDate" : ""}'
                        : 'Primary Financial Goal',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.savings_outlined, size: 20, color: AppColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Saved Amount versus Target Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatCurrency(currentSaved),
                    style: AppTypography.display.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasTarget ? 'of ${_formatCurrency(targetAmount)}' : 'saved so far',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  hasTarget ? '$percentInt% complete' : 'Tracking active',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s),

          // Progress Bar
          MMProgressBar(progress: progress, height: 6),

          const SizedBox(height: AppSpacing.m),

          // CTA Button
          MMSecondaryButton(
            label: 'View Goal →',
            onPressed: onViewGoal,
          ),
        ],
      ),
    );
  }
}
