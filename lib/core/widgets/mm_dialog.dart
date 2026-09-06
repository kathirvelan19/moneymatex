import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'mm_button.dart';

/// Reusable Modal Dialog component (8dp top radius, white container, primary/secondary action buttons)
class MMDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;

  const MMDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    required String primaryButtonLabel,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonLabel,
    VoidCallback? onSecondaryPressed,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => MMDialog(
        title: title,
        message: message,
        content: content,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderLg,
        side: BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headlineMedium),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(message!, style: AppTypography.bodyMedium),
            ],
            if (content != null) ...[
              const SizedBox(height: AppSpacing.m),
              content!,
            ],
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (secondaryButtonLabel != null && onSecondaryPressed != null) ...[
                  Expanded(
                    child: MMButton.secondary(
                      label: secondaryButtonLabel!,
                      onPressed: onSecondaryPressed!,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                ],
                Expanded(
                  child: MMButton.primary(
                    label: primaryButtonLabel,
                    onPressed: onPrimaryPressed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
