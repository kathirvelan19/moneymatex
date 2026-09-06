import 'package:flutter/foundation.dart';
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
import '../providers/tracking_settings_provider.dart';

/// Page 2 — Transaction Tracking Settings Screen
class TransactionTrackingSettingsPage extends ConsumerWidget {
  const TransactionTrackingSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(trackingSettingsProvider);
    final notifier = ref.read(trackingSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: Text(
          'Transaction Tracking',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control how MoneyMateX detects and records transactions.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            // Settings Controls List
            Text(
              'Tracking Controls',
              style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.m),

            _buildToggleTile(
              title: 'Automatic Tracking',
              subtitle: 'Detect financial transaction alerts on device',
              value: settings.automaticTracking,
              onChanged: (val) => notifier.setAutomaticTracking(val),
            ),
            const SizedBox(height: AppSpacing.m),

            _buildToggleTile(
              title: 'Transaction Notifications',
              subtitle: 'Read payment notification alerts',
              value: settings.notificationsTracking,
              onChanged: (val) => notifier.setNotificationsTracking(val),
            ),
            const SizedBox(height: AppSpacing.m),

            _buildToggleTile(
              title: 'UPI Detection',
              subtitle: 'Detect Google Pay, PhonePe, Paytm alerts',
              value: settings.upiDetection,
              onChanged: (val) => notifier.setUpiDetection(val),
            ),
            const SizedBox(height: AppSpacing.m),

            _buildToggleTile(
              title: 'Require Confirmation',
              subtitle: 'Always review detected transactions before saving (Recommended)',
              value: settings.requireConfirmation,
              onChanged: (val) => notifier.setRequireConfirmation(val),
            ),
            const SizedBox(height: AppSpacing.m),

            _buildToggleTile(
              title: 'Auto-categorization',
              subtitle: 'Automatically tag expenses into categories',
              value: settings.automaticCategorization,
              onChanged: (val) => notifier.setAutomaticCategorization(val),
            ),
            const SizedBox(height: AppSpacing.m),

            _buildToggleTile(
              title: 'Duplicate Detection',
              subtitle: 'Check for matching amounts and dates before saving',
              value: settings.duplicateDetection,
              onChanged: (val) => notifier.setDuplicateDetection(val),
            ),

            const SizedBox(height: AppSpacing.stackLg),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.m),

            // Permissions Status Section
            Text(
              'Platform Permissions',
              style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.m),

            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.l),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildPermissionRow(
                    label: 'Notifications',
                    status: !kIsWeb ? (settings.notificationsTracking ? 'Allowed' : 'Not allowed') : 'Not supported on Web',
                    isAllowed: settings.notificationsTracking && !kIsWeb,
                  ),
                  const Divider(color: AppColors.outlineVariant),
                  _buildPermissionRow(
                    label: 'Camera',
                    status: 'Available',
                    isAllowed: true,
                  ),
                  const Divider(color: AppColors.outlineVariant),
                  _buildPermissionRow(
                    label: 'Storage / Photos',
                    status: 'Available',
                    isAllowed: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.stackLg),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.m),

            // How It Works 4-Step Explanation Section
            Text(
              'How it works',
              style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.m),

            _buildStepRow('1', 'MoneyMateX detects a transaction', 'Alert received from SMS, notification, or OCR receipt scan.'),
            const SizedBox(height: AppSpacing.m),
            _buildStepRow('2', 'Transaction details are extracted', 'Merchant name, amount, date, and category clues are read.'),
            const SizedBox(height: AppSpacing.m),
            _buildStepRow('3', 'You review the information', 'Verify and edit extracted values before confirming.'),
            const SizedBox(height: AppSpacing.m),
            _buildStepRow('4', 'Confirmed transactions are added', 'Saved directly to your records, wallets, and reports.'),

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: 'Save Preferences',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction tracking settings saved successfully.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
                context.go(AppRoutes.dashboard);
              },
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow({
    required String label,
    required String status,
    required bool isAllowed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          MMStatusChip(
            label: status,
            backgroundColor: isAllowed ? AppColors.secondaryContainer : AppColors.surfaceContainerLow,
            textColor: isAllowed ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String stepNum, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Center(
            child: Text(
              stepNum,
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
