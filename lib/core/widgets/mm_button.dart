import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum MMButtonType { primary, secondary, text }

/// Centralized MoneyMateX Button component supporting Primary, Secondary, and Text variants
class MMButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final MMButtonType type;
  final IconData? icon;
  final bool fullWidth;

  const MMButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = MMButtonType.primary,
    this.icon,
    this.fullWidth = true,
  });

  const MMButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
  }) : type = MMButtonType.primary;

  const MMButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
  }) : type = MMButtonType.secondary;

  const MMButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  }) : type = MMButtonType.text;

  @override
  Widget build(BuildContext context) {
    final Widget buttonContent = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    Widget child;

    switch (type) {
      case MMButtonType.primary:
        child = SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderXs,
              ),
              textStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
            child: buttonContent,
          ),
        );
        break;
      case MMButtonType.secondary:
        child = SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderXs,
              ),
              textStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            child: buttonContent,
          ),
        );
        break;
      case MMButtonType.text:
        child = TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          child: buttonContent,
        );
        break;
    }

    if (fullWidth && type != MMButtonType.text) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}

/// Convenience aliases matching standard terms
class MMPrimaryButton extends MMButton {
  const MMPrimaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.fullWidth = true,
  }) : super.primary();
}

class MMSecondaryButton extends MMButton {
  const MMSecondaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.fullWidth = true,
  }) : super.secondary();
}

class MMTextButton extends MMButton {
  const MMTextButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.icon,
    super.fullWidth = false,
  }) : super.text();
}
