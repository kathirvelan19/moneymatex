import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_progress_bar.dart';

/// Standardized Onboarding Progress Indicator Header for all 10 MoneyMateX steps.
/// Placed strictly at the TOP of every onboarding screen.
class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep; // 1 to 10
  final int totalSteps; // 10

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 10,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentStep / totalSteps).clamp(0.1, 1.0);
    final int percentage = currentStep * 10;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.marginMobile,
        right: AppSpacing.marginMobile,
        top: AppSpacing.s,
        bottom: AppSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP $currentStep OF $totalSteps',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          MMProgressBar(progress: progress, height: 4),
        ],
      ),
    );
  }
}
