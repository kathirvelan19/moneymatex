import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// Recent Transactions Card driven 100% by user data with a friendly empty state
class RecentTransactionsCard extends StatelessWidget {
  final List<TransactionItem> transactions;
  final VoidCallback onViewAll;
  final VoidCallback onAddTransaction;

  const RecentTransactionsCard({
    super.key,
    required this.transactions,
    required this.onViewAll,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTransactions = transactions.isNotEmpty;

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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (hasTransactions)
                InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      'View All →',
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

          if (!hasTransactions) ...[
            // Friendly Empty State Widget (When user has 0 transactions)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.l),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'No transactions yet',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connect an account or add your first transaction to start tracking your money.',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  MMPrimaryButton(
                    label: '+ Add Transaction',
                    onPressed: onAddTransaction,
                    fullWidth: false,
                  ),
                ],
              ),
            ),
          ] else ...[
            // User's Real Transactions List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.take(5).length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 16, color: AppColors.outlineVariant),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainerLow,
                      ),
                      child: Icon(
                        tx.icon,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${tx.category} • ${_formatDate(tx.date)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${tx.isExpense ? "-" : "+"}₹${tx.amount.toInt()}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: tx.isExpense ? AppColors.onSurface : const Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
