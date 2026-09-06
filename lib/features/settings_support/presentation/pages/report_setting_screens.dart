import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../features/auth_onboarding/presentation/providers/user_profile_provider.dart';
import '../../../../features/auth_onboarding/presentation/providers/auth_provider.dart';

/// Stitch Screen: MoneyMateX More / Settings Screen (5274b8189d4b4ef4b699011cda4bea28)
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final userName = userProfile.name.isNotEmpty ? userProfile.name : 'MoneyMateX User';
    final userOccupation = userProfile.occupation.isNotEmpty ? userProfile.occupation : 'Member';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        title: Text(
          'More Menu & Options',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: AppTypography.headlineMedium.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userOccupation,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const MMStatusChip(
                          label: 'Active',
                          backgroundColor: Color(0xFFE8F5E9),
                          textColor: Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  Text(
                    'FINANCIAL TOOLS & HUB',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),

                  _buildTile(
                    context,
                    title: 'K2i AI Advisor',
                    subtitle: 'Your personal financial intelligence assistant',
                    icon: Icons.psychology_outlined,
                    iconColor: AppColors.primary,
                    onTap: () => context.go(AppRoutes.aiAdvisor),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Add Money / Deposit',
                    subtitle: 'Deposit funds to account and record income transactions',
                    icon: Icons.add_circle_outline,
                    iconColor: AppColors.primary,
                    onTap: () => context.go(AppRoutes.addMoney),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Reports & Analytics',
                    subtitle: 'View real expense breakdowns and income vs spending ratios',
                    icon: Icons.pie_chart_outline,
                    iconColor: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.reports),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Income & Cash Flow',
                    subtitle: 'Detailed net cash flow statements and income sources',
                    icon: Icons.show_chart_outlined,
                    iconColor: const Color(0xFF2E7D32),
                    onTap: () => context.go(AppRoutes.cashFlow),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Financial Health',
                    subtitle: 'Deterministic financial health score and AI analysis',
                    icon: Icons.health_and_safety_outlined,
                    iconColor: AppColors.tertiary,
                    onTap: () => context.go(AppRoutes.aiHealthScore),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Weekly Briefing',
                    subtitle: 'Weekly spending trends, top category, and AI recommendations',
                    icon: Icons.calendar_view_week_outlined,
                    iconColor: AppColors.aiAccent,
                    onTap: () => context.go(AppRoutes.weeklyBriefing),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Financial Profile',
                    subtitle: 'View and update your financial information',
                    icon: Icons.person_outline,
                    iconColor: AppColors.primary,
                    onTap: () => context.go(AppRoutes.financialProfile),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Wallets & Accounts',
                    subtitle: 'Manage your bank accounts, cash and wallets',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.wallets),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Bills & Reminders',
                    subtitle: 'Manage upcoming commitments and bill payments',
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.bills),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Payment Methods',
                    subtitle: 'Configure primary payment method for transactions',
                    icon: Icons.credit_card_outlined,
                    iconColor: AppColors.tertiary,
                    onTap: () => context.go(AppRoutes.paymentMethods),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Tracking Setup',
                    subtitle: 'Configure automatic tracking and alert preferences',
                    icon: Icons.tune_outlined,
                    iconColor: AppColors.primary,
                    onTap: () => context.go(AppRoutes.trackingSetup),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Help & Support',
                    subtitle: 'FAQs, support and assistance',
                    icon: Icons.help_outline,
                    iconColor: AppColors.tertiary,
                    onTap: () => context.go(AppRoutes.helpSupportCenter),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  Text(
                    'ACCOUNT & PREFERENCES',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),

                  _buildTile(
                    context,
                    title: 'Financial Onboarding Profile',
                    subtitle: 'Review or update income, priorities, and goal survey',
                    icon: Icons.person_outline,
                    iconColor: AppColors.primary,
                    onTap: () => context.go(AppRoutes.onboarding),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildTile(
                    context,
                    title: 'Privacy & Data Security',
                    subtitle: 'Manage local encryption and data storage',
                    icon: Icons.security_outlined,
                    iconColor: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.privacyDataCenter),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: 'Log Out',
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                    type: MMButtonType.secondary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class PrivacyDataCenterPage extends StatelessWidget {
  const PrivacyDataCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Data Security')),
      body: const Center(child: Text('Data stored locally in device storage.')),
    );
  }
}

class HelpSupportCenterPage extends StatelessWidget {
  const HelpSupportCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support Center')),
      body: const Center(child: Text('MoneyMateX Support & FAQs.')),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const HelpSupportCenterPage();
  }
}

class AboutLegalCenterPage extends StatelessWidget {
  const AboutLegalCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About & Legal')),
      body: const Center(child: Text('MoneyMateX v1.0.0')),
    );
  }
}
