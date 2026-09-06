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
import '../providers/user_wallets_provider.dart';

/// Stitch Screen 7 — Payment Methods Management Screen
class PaymentMethodsPage extends ConsumerWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(userWalletsProvider);
    final notifier = ref.read(userWalletsProvider.notifier);

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
          'Payment Methods',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your linked accounts & default payment methods for fast checkout and expense logging.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            if (wallets.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.credit_card_off_outlined, size: 48, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'No Payment Methods Linked',
                      style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your bank account, UPI ID, or credit card to enable quick transactions.',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    MMButton(
                      label: '+ Add Payment Method',
                      onPressed: () => context.push(AppRoutes.addWalletSelection),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: wallets.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (context, index) {
                  final wallet = wallets[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      border: Border.all(
                        color: wallet.isPrimary ? AppColors.primary : AppColors.outlineVariant,
                        width: wallet.isPrimary ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.m),
                          ),
                          child: Icon(
                            wallet.type == 'UPI'
                                ? Icons.qr_code_scanner
                                : wallet.type == 'Credit Card'
                                    ? Icons.credit_card
                                    : Icons.account_balance,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    wallet.name,
                                    style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  if (wallet.isPrimary) ...[
                                    const SizedBox(width: 8),
                                    const MMStatusChip(
                                      label: 'Default',
                                      backgroundColor: AppColors.primary,
                                      textColor: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${wallet.provider} • ${wallet.type} • ₹${wallet.balance.toInt()}',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'primary') {
                              notifier.setPrimary(wallet.id);
                            } else if (val == 'delete') {
                              notifier.removeWallet(wallet.id);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'primary', child: Text('Set as Default')),
                            const PopupMenuItem(value: 'delete', child: Text('Remove Method', style: TextStyle(color: AppColors.error))),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.l),

              MMButton(
                label: '+ Add New Payment Method',
                type: MMButtonType.secondary,
                onPressed: () => context.push(AppRoutes.addWalletSelection),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
