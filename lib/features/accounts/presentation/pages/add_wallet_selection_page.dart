import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_text_field.dart';
import '../providers/user_wallets_provider.dart';

class AccountTypeOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final String defaultProvider;

  const AccountTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.defaultProvider,
  });
}

/// Stitch Screen 1 — Add Wallet / Add Account
class AddWalletSelectionPage extends ConsumerStatefulWidget {
  const AddWalletSelectionPage({super.key});

  @override
  ConsumerState<AddWalletSelectionPage> createState() => _AddWalletSelectionPageState();
}

class _AddWalletSelectionPageState extends ConsumerState<AddWalletSelectionPage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  bool _isPrimary = false;
  String? _nameError;
  String? _balanceError;

  final List<AccountTypeOption> _options = const [
    AccountTypeOption(
      title: 'Bank Account',
      subtitle: 'Track your bank account balance',
      icon: Icons.account_balance_outlined,
      defaultProvider: 'HDFC Bank',
    ),
    AccountTypeOption(
      title: 'Debit Card',
      subtitle: 'Track spending through your debit card',
      icon: Icons.credit_card_outlined,
      defaultProvider: 'Debit Card',
    ),
    AccountTypeOption(
      title: 'Credit Card',
      subtitle: 'Track spending and credit limit',
      icon: Icons.credit_card,
      defaultProvider: 'Credit Card',
    ),
    AccountTypeOption(
      title: 'UPI',
      subtitle: 'Track all digital payments via UPI',
      icon: Icons.qr_code_scanner,
      defaultProvider: 'UPI',
    ),
    AccountTypeOption(
      title: 'Cash',
      subtitle: 'Track physical cash balance',
      icon: Icons.payments_outlined,
      defaultProvider: 'Cash',
    ),
    AccountTypeOption(
      title: 'Digital Wallet',
      subtitle: 'Track digital wallets like Paytm, PhonePe',
      icon: Icons.account_balance_wallet_outlined,
      defaultProvider: 'Paytm Wallet',
    ),
    AccountTypeOption(
      title: 'Other',
      subtitle: 'Track any other account type',
      icon: Icons.add_circle_outline,
      defaultProvider: 'Other',
    ),
  ];

  void _openAccountForm(AccountTypeOption option) {
    setState(() {
      _nameController.text = option.title == 'Other' ? '' : option.title;
      _providerController.text = option.defaultProvider;
      _balanceController.text = '';
      _isPrimary = false;
      _nameError = null;
      _balanceError = null;
    });

    showModalBottomSheet(

      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
                top: AppSpacing.l,
                left: AppSpacing.l,
                right: AppSpacing.l,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.m),
                          ),
                          child: Icon(option.icon, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add ${option.title}',
                              style: AppTypography.headlineMedium,
                            ),
                            Text(
                              option.subtitle,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    MMTextField(
                      label: 'Account Name',
                      hint: 'e.g. Primary HDFC Account',
                      controller: _nameController,
                      errorText: _nameError,
                      onChanged: (val) {
                        if (_nameError != null) setModalState(() => _nameError = null);
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    MMTextField(
                      label: 'Initial Balance (₹)',
                      hint: 'e.g. 10000',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: _balanceController,
                      errorText: _balanceError,
                      onChanged: (val) {
                        if (_balanceError != null) setModalState(() => _balanceError = null);
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    MMTextField(
                      label: 'Bank / Provider Name',
                      hint: 'e.g. HDFC, PhonePe, SBI',
                      controller: _providerController,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Set as primary wallet', style: AppTypography.bodyLarge),
                        Switch.adaptive(
                          value: _isPrimary,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setModalState(() => _isPrimary = val);
                            setState(() => _isPrimary = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    MMButton(
                      label: 'Save Account',
                      onPressed: () async {
                        final name = _nameController.text.trim();
                        final balStr = _balanceController.text.trim();

                        bool valid = true;
                        if (name.isEmpty) {
                          setModalState(() => _nameError = 'Please enter account name');
                          valid = false;
                        }
                        if (balStr.isEmpty || double.tryParse(balStr) == null) {
                          setModalState(() => _balanceError = 'Please enter a valid balance');
                          valid = false;
                        }
                        if (!valid) return;

                        final balance = double.parse(balStr);
                        final provider = _providerController.text.trim().isEmpty ? option.defaultProvider : _providerController.text.trim();

                        final newWallet = WalletItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          type: option.title,
                          provider: provider,
                          balance: balance,
                          createdAt: DateTime.now(),
                          trackingMethod: option.title == 'UPI' || option.title == 'Bank Account' ? 'Automatic' : 'Manual',
                          isPrimary: _isPrimary,
                        );

                        await ref.read(userWalletsProvider.notifier).addWallet(newWallet);

                        if (context.mounted) {
                          Navigator.of(context).pop(); // Close sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${newWallet.name} added with balance ₹${newWallet.balance.toInt()}'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.dashboard);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Add Wallet',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose where you want to track your money.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            // Account type cards list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _options.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) {
                final option = _options[index];
                return InkWell(
                  onTap: () => _openAccountForm(option),
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
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
                          child: Icon(option.icon, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.title,
                                style: AppTypography.headlineMedium.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                option.subtitle,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.stackLg),

            // Privacy & security notice card
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.l),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your assets matter',
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We encrypt and protect all your financial data. MoneyMateX never stores banking credentials or PINs.',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
