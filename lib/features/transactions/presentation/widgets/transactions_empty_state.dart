import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';

/// Premium Empty State Widget for Transactions Screen
class TransactionsEmptyState extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onClearFilters;
  final VoidCallback onAddExpense;
  final VoidCallback onScanReceipt;

  const TransactionsEmptyState({
    super.key,
    required this.isFiltered,
    required this.onClearFilters,
    required this.onAddExpense,
    required this.onScanReceipt,
  });

  @override
  Widget build(BuildContext context) {
    if (isFiltered) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 28,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'No matching transactions',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'We couldn\'t find any transactions matching your filter or search query.',
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            MMSecondaryButton(
              label: 'Clear Filters',
              onPressed: onClearFilters,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'No transactions recorded yet',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep track of your income and daily spending to unlock smart MoneyMateX insights.',
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: MMPrimaryButton(
                  label: '+ Add Expense',
                  onPressed: onAddExpense,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: MMSecondaryButton(
                  label: 'Scan Receipt',
                  onPressed: onScanReceipt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
