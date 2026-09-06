import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_chip.dart';

/// Reusable Wallet Card Component for Screen #32 (Wallets Overview View A)
class MMWalletCard extends StatelessWidget {
  final String accountName;
  final String accountType;
  final String accountNumber;
  final String balance;
  final String changePercentage;
  final IconData icon;
  final Color cardColor;
  final bool isPrimary;
  final VoidCallback? onTap;

  const MMWalletCard({
    super.key,
    required this.accountName,
    required this.accountType,
    required this.accountNumber,
    required this.balance,
    this.changePercentage = '+2.4%',
    required this.icon,
    this.cardColor = AppColors.primary,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.outlineVariant,
            width: isPrimary ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(icon, color: cardColor, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accountName,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '$accountType • $accountNumber',
                          style: AppTypography.labelSmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isPrimary)
                  const MMStatusChip(
                    label: 'PRIMARY',
                    backgroundColor: AppColors.primaryContainer,
                    textColor: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AVAILABLE BALANCE', style: AppTypography.labelSmall.copyWith(fontSize: 10, letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(
                      balance,
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                MMStatusChip(
                  label: changePercentage,
                  backgroundColor: const Color(0xFFE8F5E9),
                  textColor: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
