import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_progress_bar.dart';

/// Stitch Screen: MoneyMateX Onboarding Introduction
/// Screen ID: 2b72cbe1978c43188223ca9b3fe3e3bd
/// Canvas Dimensions: 780 × 2112 px (Mobile 390 × 844 dp @2x scale)
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s),

              // Header & Progress Step
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "LET'S PERSONALIZE YOUR EXPERIENCE",
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '1 of 10',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              const MMSegmentedProgressBar(currentStep: 1, totalSteps: 10),

              const SizedBox(height: AppSpacing.stackLg),

              // Main Content Scroll Area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Abstract Financial Growth Visualization
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Concentric Circles
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                                ),
                              ),
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                ),
                              ),

                              // Vertical Bar Growth Chart
                              Positioned(
                                bottom: 24,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 64,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.stackLg),

                      // Typography & Messaging
                      Text(
                        "Let's build your money plan.",
                        style: AppTypography.headlineMobile.copyWith(color: AppColors.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Text(
                        'Answer a few quick questions so MoneyMateX can understand your financial situation and personalize your experience.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),

                      const SizedBox(height: AppSpacing.stackSm),

                      // Time Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.outlineVariant, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 16, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              'About 2 minutes',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.stackLg),

                      // Benefits Section
                      Text(
                        'Your answers help us personalize:',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.s),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          border: Border.all(color: AppColors.outlineVariant, width: 1),
                        ),
                        child: const Column(
                          children: [
                            _BenefitRow(label: 'Budgets', isFirst: true),
                            Divider(height: 1, color: AppColors.outlineVariant),
                            _BenefitRow(label: 'Savings goals'),
                            Divider(height: 1, color: AppColors.outlineVariant),
                            _BenefitRow(label: 'Spending insights'),
                            Divider(height: 1, color: AppColors.outlineVariant),
                            _BenefitRow(label: 'AI recommendations', isLast: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.stackLg),
                    ],
                  ),
                ),
              ),

              // Footer & Action Buttons
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.m),
                child: Column(
                  children: [
                    // Privacy Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Your financial information stays private and secure.',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Primary Button
                    MMPrimaryButton(
                      label: "Let's Get Started",
                      onPressed: () => context.go(AppRoutes.occupation),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Secondary / Skip Button
                    MMTextButton(
                      label: 'Skip for now',
                      onPressed: () => context.go(AppRoutes.occupation),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String label;
  final bool isFirst;
  final bool isLast;

  const _BenefitRow({
    required this.label,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
