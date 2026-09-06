import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Transaction row component displaying icon, category, title, timestamp, and Geist monetary amount
class MMTransactionRow extends StatelessWidget {
  final String title;
  final String category;
  final String amount;
  final String timestamp;
  final IconData? icon;
  final bool isExpense;
  final VoidCallback? onTap;

  const MMTransactionRow({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.timestamp,
    this.icon,
    this.isExpense = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Icon(
          icon ?? Icons.receipt_long_outlined,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.onBackground),
      ),
      subtitle: Text(
        '$category • $timestamp',
        style: AppTypography.labelSmall,
      ),
      trailing: Text(
        amount,
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: isExpense ? AppColors.onBackground : AppColors.tertiary,
        ),
      ),
    );
  }
}

typedef MMTransactionTile = MMTransactionRow;
