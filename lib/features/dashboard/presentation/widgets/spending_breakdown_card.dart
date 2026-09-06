import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// "Where Your Money Goes" Spending Breakdown Card driven 100% by user's real transactions
class SpendingBreakdownCard extends StatelessWidget {
  final List<TransactionItem> transactions;
  final VoidCallback onViewAnalysis;

  const SpendingBreakdownCard({
    super.key,
    required this.transactions,
    required this.onViewAnalysis,
  });

  String _formatCurrency(double amount) {
    return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final expenses = transactions.where((tx) => tx.isExpense).toList();
    final double totalExpenseAmount =
        expenses.fold(0.0, (sum, tx) => sum + tx.amount);

    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    final Map<String, IconData> categoryIcons = {};

    for (final tx in expenses) {
      final cat = tx.category.isNotEmpty ? tx.category : 'General';
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + tx.amount;
      categoryIcons[cat] = tx.icon;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bool hasData = sortedCategories.isNotEmpty && totalExpenseAmount > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Where Your Money Goes',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              InkWell(
                onTap: onViewAnalysis,
                borderRadius: BorderRadius.circular(AppRadius.s),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    'View Analysis →',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          if (!hasData) ...[
            // Empty State when user has 0 recorded expense categories
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.l),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.donut_small_outlined,
                    size: 32,
                    color: AppColors.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No expense breakdown yet',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add expenses to automatically categorize your spending.',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Category List calculated dynamically from user's real transactions
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedCategories.take(5).length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, index) {
                final entry = sortedCategories[index];
                final String catName = entry.key;
                final double catAmount = entry.value;
                final double catRatio = (catAmount / totalExpenseAmount).clamp(0.0, 1.0);
                final int catPercent = (catRatio * 100).round();
                final IconData icon = categoryIcons[catName] ?? Icons.category_outlined;

                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainerLow,
                      ),
                      child: Icon(icon, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                catName,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _formatCurrency(catAmount),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$catPercent%',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          MMProgressBar(
                            progress: catRatio,
                            height: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
