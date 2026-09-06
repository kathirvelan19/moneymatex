import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_chip.dart';

/// Premium Cash Flow Hero Summary Card for Transactions Screen
class TransactionsHeroSummaryCard extends StatelessWidget {
  final double inflow;
  final double outflow;
  final int inflowCount;
  final int outflowCount;
  final String monthLabel;

  const TransactionsHeroSummaryCard({
    super.key,
    required this.inflow,
    required this.outflow,
    required this.inflowCount,
    required this.outflowCount,
    this.monthLabel = 'AUGUST CASH FLOW',
  });

  String _formatCurrency(double amount) {
    return '₹${amount.toInt().abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final double netCashFlow = inflow - outflow;
    final bool isPositive = netCashFlow >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthLabel.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const MMStatusChip(
                label: 'All Wallets',
                backgroundColor: AppColors.secondaryContainer,
                textColor: AppColors.onSecondaryContainer,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Inflow & Outflow Cards Row
          Row(
            children: [
              // Inflow (Income) Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7), // Soft Emerald Tint
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(
                      color: const Color(0xFF86EFAC).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.south_west_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'INFLOW',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF166534),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+${_formatCurrency(inflow)}',
                        style: AppTypography.headlineMedium.copyWith(
                          color: const Color(0xFF15803D),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '$inflowCount transaction${inflowCount == 1 ? "" : "s"}',
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF166534).withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.s),

              // Outflow (Spent) Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.north_east_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'OUTFLOW',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '-${_formatCurrency(outflow)}',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '$outflowCount transaction${outflowCount == 1 ? "" : "s"}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Net Cash Flow Badge Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPositive ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(
                color: isPositive ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Net Cash Flow',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${isPositive ? "+" : "-"}${_formatCurrency(netCashFlow)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isPositive ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
