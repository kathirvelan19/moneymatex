import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class MMAIBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const MMAIBubble({
    super.key,
    required this.message,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.s),
          color: isUser ? AppColors.primaryContainer : AppColors.surfaceContainerHighest,
          border: Border.all(
            color: isUser ? AppColors.primary : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: isUser ? AppColors.onPrimaryContainer : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
