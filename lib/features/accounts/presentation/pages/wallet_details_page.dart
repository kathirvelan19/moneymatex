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
import '../../../../core/widgets/mm_empty_state.dart';
import '../../../../core/widgets/mm_section_header.dart';
import '../../../../core/widgets/mm_transaction_tile.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../providers/user_wallets_provider.dart';

String _formatCurrency(num amount) {
  final str = amount.toStringAsFixed(0);
  final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$result';
}

/// Stitch Screen: MoneyMateX Wallet / Account Details Screen
/// Entry Point: More → Wallets → Select Wallet
class WalletDetailsPage extends ConsumerStatefulWidget {
  final String walletId;
  const WalletDetailsPage({super.key, required this.walletId});

  @override
  ConsumerState<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends ConsumerState<WalletDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(userWalletsProvider);
    final allTransactions = ref.watch(transactionsProvider);

    final wallet = wallets.firstWhere(
      (w) => w.id == widget.walletId || w.name == widget.walletId,
      orElse: () => WalletItem(
        id: widget.walletId,
        name: 'Primary Account',
        type: 'Bank Account',
        provider: 'Bank',
        balance: 0.0,
        createdAt: DateTime.now(),
        trackingMethod: 'Manual',
        isPrimary: true,
      ),
    );

    // Filter transactions belonging to this wallet
    final walletTransactions = allTransactions.where(
      (t) => t.wallet.toLowerCase() == wallet.name.toLowerCase() || t.wallet == wallet.id
    ).toList();

    final double totalIncome = walletTransactions.where((t) => !t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
    final double totalExpenses = walletTransactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.wallets);
            }
          },
        ),
        title: Text(
          wallet.name,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Money to Wallet',
            onPressed: () => context.go(AppRoutes.addMoney),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
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
                  // Wallet Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B2E91), Color(0xFF7B3EC4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              wallet.type.toUpperCase(),
                              style: AppTypography.labelSmall.copyWith(color: Colors.white70, letterSpacing: 0.8),
                            ),
                            if (wallet.isPrimary)
                              const MMStatusChip(
                                label: 'Primary',
                                backgroundColor: Colors.white24,
                                textColor: Colors.white,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          _formatCurrency(wallet.balance),
                          style: AppTypography.display.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Current Available Balance (${wallet.provider})',
                          style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.m),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('LOGGED INFLOWS', style: AppTypography.labelSmall.copyWith(color: Colors.white70, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatCurrency(totalIncome),
                                      style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.m),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('LOGGED OUTFLOWS', style: AppTypography.labelSmall.copyWith(color: Colors.white70, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatCurrency(totalExpenses),
                                      style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Wallet Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: MMPrimaryButton(
                          label: '+ Add Money',
                          onPressed: () => context.go(AppRoutes.addMoney),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: MMSecondaryButton(
                          label: '- Log Expense',
                          onPressed: () => context.go(AppRoutes.addExpense),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Account Details Section
                  const MMSectionHeader(
                    title: 'Account Information',
                    subtitle: 'Tracking method and primary status',
                  ),
                  const SizedBox(height: AppSpacing.s),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Account Type', wallet.type),
                        const Divider(height: 16),
                        _buildInfoRow('Provider / Bank', wallet.provider),
                        const Divider(height: 16),
                        _buildInfoRow('Tracking Method', wallet.trackingMethod),
                        const Divider(height: 16),
                        _buildInfoRow('Primary Account', wallet.isPrimary ? 'Yes' : 'No'),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Recent Wallet Transactions Section
                  MMSectionHeader(
                    title: 'Wallet Transactions',
                    subtitle: '${walletTransactions.length} recorded transactions for ${wallet.name}',
                  ),
                  const SizedBox(height: AppSpacing.s),

                  if (walletTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: MMEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Transactions for This Wallet',
                        subtitle: 'Transactions linked to ${wallet.name} will appear here automatically.',
                        actionLabel: '+ Add Money / Deposit',
                        onAction: () => context.go(AppRoutes.addMoney),
                      ),
                    )
                  else
                    ...walletTransactions.map((t) {
                      return MMTransactionTile(
                        title: t.title,
                        category: t.category,
                        amount: '${t.isExpense ? '-' : '+'}${_formatCurrency(t.amount)}',
                        timestamp: t.date.toString().split(' ')[0],
                        icon: t.icon,
                        isExpense: t.isExpense,
                        onTap: () => context.go('/transactions/${t.id}'),
                      );
                    }),

                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
        Text(value, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// Detailed Wallets list & account overview page
class WalletsDetailedPage extends StatelessWidget {
  const WalletsDetailedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalletDetailsPage(walletId: 'primary');
  }
}
