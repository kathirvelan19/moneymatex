import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_progress_bar.dart';

/// Premium "This Month" Spending Card with Fixed Costs Switch
class MonthlySummaryCard extends StatefulWidget {
  final double totalSpent;
  final double budgetLimit;
  final int percentVsLastMonth;
  final bool isUnderBudget;
  final VoidCallback onViewTransactions;

  const MonthlySummaryCard({
    super.key,
    required this.totalSpent,
    required this.budgetLimit,
    this.percentVsLastMonth = 12,
    this.isUnderBudget = true,
    required this.onViewTransactions,
  });

  @override
  State<MonthlySummaryCard> createState() => _MonthlySummaryCardState();
}

class _MonthlySummaryCardState extends State<MonthlySummaryCard> {
  bool _fixedCostsEnabled = true;

  String _formatCurrency(double amount) {
    return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final double spentProgress =
        widget.budgetLimit > 0 ? (widget.totalSpent / widget.budgetLimit).clamp(0.0, 1.0) : 0.0;

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
                'This Month',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s),

          // Total Spent Amount
          Text(
            'Total spent',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatCurrency(widget.totalSpent),
                style: AppTypography.display.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.s),

              // Semantic Trend Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.isUnderBudget
                      ? const Color(0xFFDCFCE7) // Light green fill
                      : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isUnderBudget ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 12,
                      color: widget.isUnderBudget
                          ? const Color(0xFF15803D) // Green text
                          : AppColors.onErrorContainer,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.percentVsLastMonth}% ${widget.isUnderBudget ? "Under budget" : "Over budget"}',
                      style: AppTypography.labelSmall.copyWith(
                        color: widget.isUnderBudget
                            ? const Color(0xFF15803D)
                            : AppColors.onErrorContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Spending Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly spending',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              Text(
                '${(spentProgress * 100).toInt()}% of ${_formatCurrency(widget.budgetLimit)}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          MMProgressBar(progress: spentProgress, height: 5),

          const SizedBox(height: AppSpacing.m),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: AppSpacing.s),

          // Fixed Costs Real Flutter Switch Toggle Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lock_clock_outlined,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fixed costs included',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _fixedCostsEnabled,
                activeTrackColor: AppColors.primaryContainer,
                onChanged: (val) {
                  setState(() {
                    _fixedCostsEnabled = val;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s),

          // Action Button
          MMSecondaryButton(
            label: 'View Transactions →',
            onPressed: widget.onViewTransactions,
          ),
        ],
      ),
    );
  }
}
