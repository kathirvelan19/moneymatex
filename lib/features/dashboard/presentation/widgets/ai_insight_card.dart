import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';

/// MoneyMateX AI Insight Card displaying dynamic insight generated from real user data
class AiInsightCard extends StatelessWidget {
  final double totalSpent;
  final double budgetLimit;
  final String? topCategory;
  final VoidCallback onViewInsight;
  final VoidCallback onAskAI;

  const AiInsightCard({
    super.key,
    required this.totalSpent,
    required this.budgetLimit,
    this.topCategory,
    required this.onViewInsight,
    required this.onAskAI,
  });

  String _formatCurrency(double amount) {
    return '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSpending = totalSpent > 0;
    final String headlineText = hasSpending
        ? "You've spent ${_formatCurrency(totalSpent)} this month."
        : "Start tracking your spending";

    final String subText = hasSpending
        ? (topCategory != null && topCategory!.isNotEmpty
            ? "Your highest category so far is $topCategory. Keep monitoring expenses to reach your financial goals."
            : "Keep recording transactions to unlock smart MoneyMateX AI optimization tips.")
        : "Record your daily expenses or connect your accounts to receive personalized MoneyMateX AI insights.";

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.aiContainer,
            Color(0xFFEDE9FE), // Soft Lavender
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.aiAccent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.aiAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.aiAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    'MoneyMateX AI',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.aiAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'SMART ADVISOR',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.aiAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Insight Content driven by real user data
          Text(
            headlineText,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: AppSpacing.l),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: MMPrimaryButton(
                  label: 'View Insight',
                  onPressed: onViewInsight,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: MMSecondaryButton(
                  label: 'Ask AI Advisor',
                  onPressed: onAskAI,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
