import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable Bottom Sheet component for filters, category pickers, and options
class MMBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  const MMBottomSheet({
    super.key,
    this.title,
    required this.child,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MMBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(title!, style: AppTypography.headlineMedium),
          ],
          const SizedBox(height: AppSpacing.m),
          child,
        ],
      ),
    );
  }
}
