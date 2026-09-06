import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'mm_button.dart';

/// Reusable Error State component for failed network requests or data loading errors
class MMErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final String retryLabel;
  final VoidCallback? onRetry;

  const MMErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.retryLabel = 'Try Again',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.l),
              MMButton(
                label: retryLabel,
                onPressed: onRetry!,
                type: MMButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
