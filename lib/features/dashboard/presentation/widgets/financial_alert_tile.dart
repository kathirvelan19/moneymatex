import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_chip.dart';

enum AlertPriority { critical, warning, info, success }

/// Reusable Alert Card component for Financial Alerts Center (Screen #22)
class FinancialAlertTile extends StatelessWidget {
  final String title;
  final String description;
  final String timestamp;
  final AlertPriority priority;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onTap;
  final bool isUnread;

  const FinancialAlertTile({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    this.priority = AlertPriority.info,
    this.actionLabel,
    this.onAction,
    this.onTap,
    this.isUnread = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getPriorityColors();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: isUnread ? colors.backgroundColor : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isUnread ? colors.borderColor : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(colors.icon, color: colors.iconColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MMStatusChip(
                            label: colors.label,
                            backgroundColor: colors.badgeBgColor,
                            textColor: colors.iconColor,
                          ),
                          Text(
                            timestamp,
                            style: AppTypography.labelSmall.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.m),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onAction,
                  icon: Icon(Icons.arrow_forward, size: 16, color: colors.iconColor),
                  label: Text(
                    actionLabel!,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _PriorityColors _getPriorityColors() {
    switch (priority) {
      case AlertPriority.critical:
        return _PriorityColors(
          backgroundColor: AppColors.errorContainer.withValues(alpha: 0.25),
          borderColor: AppColors.error.withValues(alpha: 0.4),
          badgeBgColor: AppColors.errorContainer,
          iconColor: AppColors.error,
          icon: Icons.warning_amber_rounded,
          label: 'CRITICAL WARNING',
        );
      case AlertPriority.warning:
        return _PriorityColors(
          backgroundColor: AppColors.tertiaryContainer.withValues(alpha: 0.15),
          borderColor: AppColors.tertiary.withValues(alpha: 0.4),
          badgeBgColor: AppColors.tertiaryFixed,
          iconColor: AppColors.onTertiaryContainer,
          icon: Icons.notifications_active_outlined,
          label: 'REMINDER',
        );
      case AlertPriority.info:
        return _PriorityColors(
          backgroundColor: AppColors.aiContainer,
          borderColor: AppColors.primaryContainer.withValues(alpha: 0.3),
          badgeBgColor: AppColors.primaryContainer.withValues(alpha: 0.2),
          iconColor: AppColors.aiAccent,
          icon: Icons.auto_awesome,
          label: 'AI INSIGHT',
        );
      case AlertPriority.success:
        return _PriorityColors(
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
          badgeBgColor: const Color(0xFFC8E6C9),
          iconColor: const Color(0xFF2E7D32),
          icon: Icons.check_circle_outline,
          label: 'RESOLVED',
        );
    }
  }
}

class _PriorityColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color badgeBgColor;
  final Color iconColor;
  final IconData icon;
  final String label;

  _PriorityColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeBgColor,
    required this.iconColor,
    required this.icon,
    required this.label,
  });
}
