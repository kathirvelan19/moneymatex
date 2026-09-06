import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'mm_button.dart';

/// Reusable AI Insight Card component (Purple tinted container #F5F3FF with sparkle header & action button)
class MMAIInsightCard extends StatelessWidget {
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MMAIInsightCard({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.aiContainer,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.aiAccent, size: 20),
              const SizedBox(width: AppSpacing.s),
              Text(
                'K2i AI INSIGHT',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.aiAccent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(title, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.s),
          Text(description, style: AppTypography.bodyMedium),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.m),
            MMButton(
              label: actionLabel!,
              onPressed: onAction!,
              type: MMButtonType.primary,
              fullWidth: false,
            ),
          ],
        ],
      ),
    );
  }
}
