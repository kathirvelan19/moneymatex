import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/transaction_entity.dart';

/// Section Group displaying chronologically grouped transactions (e.g. Today, Yesterday)
class TransactionGroupSection extends StatelessWidget {
  final String sectionTitle;
  final List<TransactionItem> items;
  final Function(TransactionItem) onItemTap;

  const TransactionGroupSection({
    super.key,
    required this.sectionTitle,
    required this.items,
    required this.onItemTap,
  });

  String _formatCurrency(double amount) {
    return '₹${amount.toInt().abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final double sectionTotalOutflow = items
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final double sectionTotalInflow = items
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s, top: AppSpacing.m),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                sectionTotalInflow > 0 && sectionTotalOutflow > 0
                    ? '+${_formatCurrency(sectionTotalInflow)} / -${_formatCurrency(sectionTotalOutflow)}'
                    : (sectionTotalInflow > 0
                        ? '+${_formatCurrency(sectionTotalInflow)}'
                        : '-${_formatCurrency(sectionTotalOutflow)}'),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Group Container Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 56,
              color: AppColors.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final tx = items[index];
              return InkWell(
                onTap: () => onItemTap(tx),
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(AppRadius.xl) : Radius.zero,
                  bottom: index == items.length - 1
                      ? const Radius.circular(AppRadius.xl)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Category Icon Circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tx.isExpense
                              ? AppColors.surfaceContainerLow
                              : const Color(0xFFDCFCE7),
                        ),
                        child: Icon(
                          tx.icon,
                          size: 20,
                          color: tx.isExpense
                              ? AppColors.primary
                              : const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),

                      // Title & Subtitle Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.title,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${tx.category}${tx.paymentMethod.isNotEmpty ? " • ${tx.paymentMethod}" : ""}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Amount & Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tx.isExpense ? "-" : "+"}${_formatCurrency(tx.amount)}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: tx.isExpense
                                  ? AppColors.onSurface
                                  : const Color(0xFF15803D),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tx.formattedTime.isNotEmpty ? tx.formattedTime : tx.formattedDate,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
