import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_chip.dart';

/// Reusable Payment Method Tile component for Screen #31
class MMPaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isPrimary;
  final bool isConnected;
  final VoidCallback? onTap;
  final VoidCallback? onSettingsTap;

  const MMPaymentMethodTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.isPrimary = false,
    this.isConnected = true,
    this.onTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isPrimary ? AppColors.primary : AppColors.outlineVariant,
          width: isPrimary ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (isPrimary) ...[
              const MMStatusChip(
                label: 'PRIMARY',
                backgroundColor: AppColors.primaryContainer,
                textColor: AppColors.primary,
              ),
            ] else if (!isConnected) ...[
              const MMStatusChip(
                label: 'DISCONNECTED',
                backgroundColor: AppColors.secondaryContainer,
                textColor: AppColors.onSecondaryContainer,
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(fontSize: 12),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
          onPressed: onSettingsTap ?? () {},
        ),
      ),
    );
  }
}
