import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Centralized Card Container (White/off-white fill, 1px #CBC4D2 border, 0 shadow, 4dp radius)
class MMCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const MMCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: AppShadows.none,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: cardWidget,
      );
    }
    return cardWidget;
  }
}

/// Financial summary card displaying label, Geist monetary figure, trend badge, and optional action
class MMFinancialSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final String? trendLabel;
  final bool isPositiveTrend;
  final Widget? action;

  const MMFinancialSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.trendLabel,
    this.isPositiveTrend = true,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return MMCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.tagline),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: AppTypography.display.copyWith(fontSize: 32)),
          if (subtitle != null || trendLabel != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (trendLabel != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositiveTrend ? AppColors.tertiaryFixed : AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      trendLabel!,
                      style: AppTypography.labelSmall.copyWith(
                        color: isPositiveTrend ? AppColors.onTertiaryContainer : AppColors.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(subtitle!, style: AppTypography.labelSmall),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Chart container wrapper with title, legend header, and canvas slot
class MMChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final List<Widget>? legendItems;

  const MMChartContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.chart,
    this.legendItems,
  });

  @override
  Widget build(BuildContext context) {
    return MMCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.headlineMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTypography.tagline),
                  ],
                ],
              ),
              if (legendItems != null) Row(children: legendItems!),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }
}
