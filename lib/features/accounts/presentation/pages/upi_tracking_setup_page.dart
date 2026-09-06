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

/// Page 1 — Automatic Transaction Tracking Setup Screen
class UpiTrackingSetupPage extends ConsumerStatefulWidget {
  const UpiTrackingSetupPage({super.key});

  @override
  ConsumerState<UpiTrackingSetupPage> createState() => _UpiTrackingSetupPageState();
}

class _UpiTrackingSetupPageState extends ConsumerState<UpiTrackingSetupPage> {
  bool _isPermissionGranted = false;
  String _selectedSource = 'upi'; // 'upi', 'bank', 'card', 'other'

  bool get _isPlatformSupported => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android);

  void _requestPlatformPermission() {
    if (!_isPlatformSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Automatic SMS/Notification tracking is currently supported on Android devices only.'),
        ),
      );
      return;
    }

    setState(() {
      _isPermissionGranted = true;
    });

    ref.read(trackingSettingsProvider.notifier).setAutomaticTracking(true);
    ref.read(trackingSettingsProvider.notifier).setNotificationsTracking(true);
    ref.read(trackingSettingsProvider.notifier).setUpiDetection(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification tracking permission granted!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingSettings = ref.watch(trackingSettingsProvider);

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
          'Automatic Tracking',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automatic Transaction Tracking',
              style: AppTypography.headlineLarge.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'MoneyMateX helps detect transaction alerts automatically so you do not have to enter every expense manually.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),

            const SizedBox(height: AppSpacing.l),

            // Informational Explanation Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.l),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'Automatically capture eligible transactions so you don\'t have to enter every expense manually.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.stackLg),

            Text(
              'Select Source to Track',
              style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.m),

            // Source Cards: UPI, Bank Account, Card, Other
            _buildSourceCard(
              id: 'upi',
              title: 'UPI Payment Notifications',
              subtitle: 'MoneyMateX can detect eligible UPI transaction notifications on your device.',
              icon: Icons.qr_code_scanner,
            ),
            const SizedBox(height: AppSpacing.m),
            _buildSourceCard(
              id: 'bank',
              title: 'Bank SMS Notifications',
              subtitle: 'Detect debit & credit alerts from recognized bank handles.',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: AppSpacing.m),
            _buildSourceCard(
              id: 'card',
              title: 'Debit & Credit Card Alerts',
              subtitle: 'Capture card POS & online checkout transactions.',
              icon: Icons.credit_card,
            ),

            const SizedBox(height: AppSpacing.stackLg),

            // Platform capability check banner
            if (!_isPlatformSupported) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.onSurfaceVariant, size: 20),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        'Automatic tracking is not available on this platform yet. You can track transactions using Receipt Scanning or Manual Entry.',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
            ] else ...[
              // Permission Grant Box
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Notification Permission',
                          style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        MMStatusChip(
                          label: _isPermissionGranted || trackingSettings.notificationsTracking ? 'Granted' : 'Required',
                          backgroundColor: _isPermissionGranted || trackingSettings.notificationsTracking ? AppColors.secondaryContainer : AppColors.tertiaryContainer,
                          textColor: _isPermissionGranted || trackingSettings.notificationsTracking ? AppColors.onSecondaryContainer : AppColors.onTertiaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'MoneyMateX reads transaction notifications locally on your device. Your data is encrypted and never shared.',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    MMButton(
                      label: _isPermissionGranted || trackingSettings.notificationsTracking ? 'Permission Granted' : 'Grant Permission',
                      type: _isPermissionGranted || trackingSettings.notificationsTracking ? MMButtonType.secondary : MMButtonType.primary,
                      onPressed: _requestPlatformPermission,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
            ],

            // Privacy Security Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.l),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'Your transaction data is used only to organize your MoneyMateX financial records.',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.stackLg),

            // Primary Continue Button
            MMButton(
              label: 'Continue',
              onPressed: () {
                context.push(AppRoutes.trackingSettings);
              },
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedSource == id;

    return InkWell(
      onTap: () => setState(() => _selectedSource = id),
      borderRadius: BorderRadius.circular(AppRadius.l),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer.withValues(alpha: 0.3) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.l),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
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
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(
              _selectedSource == id ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: _selectedSource == id ? AppColors.primary : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
