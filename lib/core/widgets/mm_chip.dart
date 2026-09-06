import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Pill-shaped choice chip component for category filters
class MMCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final IconData? icon;

  const MMCategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            )
          : null,
      label: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected?.call(),
      backgroundColor: AppColors.surfaceContainerLow,
      selectedColor: AppColors.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          width: 1,
        ),
      ),
      elevation: 0,
      pressElevation: 0,
    );
  }
}

/// Status chip badge component (Active, Over-budget, Pending, Success)
class MMStatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const MMStatusChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor ?? AppColors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

typedef MMChip = MMCategoryChip;
