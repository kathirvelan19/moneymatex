import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Feature-specific Card component for Financial Goal option selection matching Stitch design
class MMGoalOptionCard extends StatelessWidget {
  final String? emoji;
  final IconData? icon;
  final String title;
  final bool isSelected;
  final bool isDashed;
  final VoidCallback onTap;

  const MMGoalOptionCard({
    super.key,
    this.emoji,
    this.icon,
    required this.title,
    required this.isSelected,
    this.isDashed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 104,
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDashed
                    ? AppColors.outline
                    : AppColors.outlineVariant,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (emoji != null)
                    Text(
                      emoji!,
                      style: const TextStyle(fontSize: 26),
                    )
                  else if (icon != null)
                    Icon(
                      icon,
                      size: 26,
                      color: isSelected ? AppColors.primary : AppColors.outline,
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? AppColors.onPrimaryFixedVariant : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
