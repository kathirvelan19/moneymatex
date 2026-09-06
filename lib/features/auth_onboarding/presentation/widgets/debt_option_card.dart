import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Feature-specific Card component for Debt option selection with expandable input fields matching Stitch design
class MMDebtOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final TextEditingController? outstandingController;
  final TextEditingController? monthlyPaymentController;
  final ValueChanged<String>? onOutstandingChanged;
  final ValueChanged<String>? onMonthlyPaymentChanged;
  final bool showDetailsPanel;

  const MMDebtOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.outstandingController,
    this.monthlyPaymentController,
    this.onOutstandingChanged,
    this.onMonthlyPaymentChanged,
    this.showDetailsPanel = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLow : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
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
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primaryContainer.withValues(alpha: 0.15)
                            : AppColors.surfaceContainerLow,
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: AppTypography.tagline.copyWith(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.onPrimary,
                        )
                      : null,
                ),
              ],
            ),
            if (isSelected && showDetailsPanel && outstandingController != null) ...[
              const SizedBox(height: AppSpacing.m),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.outlineVariant, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 380;
                        final fieldWidth = isWide ? (constraints.maxWidth - AppSpacing.s) / 2 : constraints.maxWidth;

                        return Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Outstanding amount (₹)',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '₹',
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: TextField(
                                            controller: outstandingController,
                                            keyboardType: TextInputType.number,
                                            onChanged: onOutstandingChanged,
                                            style: AppTypography.bodyMedium.copyWith(
                                              color: AppColors.onSurface,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: '0',
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Monthly payment (₹)',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '₹',
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: TextField(
                                            controller: monthlyPaymentController,
                                            keyboardType: TextInputType.number,
                                            onChanged: onMonthlyPaymentChanged,
                                            style: AppTypography.bodyMedium.copyWith(
                                              color: AppColors.onSurface,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: '0',
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Approximate values are enough.',
                      style: AppTypography.tagline.copyWith(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
