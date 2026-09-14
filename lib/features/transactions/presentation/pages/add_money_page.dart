import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../features/accounts/presentation/providers/user_wallets_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';

String _formatRupees(num amount) {
  final str = amount.toStringAsFixed(0);
  final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$result';
}

/// Stitch Screen: MoneyMateX Add Money / Deposit Funds Screen
/// Purpose: Add income/money to an existing account/wallet
class AddMoneyPage extends ConsumerStatefulWidget {
  const AddMoneyPage({super.key});

  @override
  ConsumerState<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends ConsumerState<AddMoneyPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
  );

  String _selectedSource = 'Salary';
  String _selectedType = 'Income';
  String? _selectedWalletId;

  final List<String> _incomeSources = const [
    'Salary',
    'Freelance',
    'Business',
    'Investments',
    'Bonus',
    'Gift',
    'Other Income',
  ];

  final List<String> _incomeTypes = const [
    'Income',
    'Deposit',
    'Transfer',
    'Refund',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _onSaveAddMoney() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount (> 0).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final wallets = ref.read(userWalletsProvider);
    final wallet = wallets.firstWhere(
      (w) => w.id == _selectedWalletId,
      orElse: () => wallets.isNotEmpty
          ? wallets.first
          : WalletItem(
              id: 'primary',
              name: 'Primary Account',
              type: 'Bank Account',
              provider: 'Bank',
              balance: 0.0,
              createdAt: DateTime.now(),
              trackingMethod: 'Manual',
            ),
    );

    DateTime date = DateTime.now();
    final parsedDate = DateTime.tryParse(_dateController.text.trim());
    if (parsedDate != null) {
      date = parsedDate;
    }

    final transaction = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Income - $_selectedSource',
      category: _selectedSource,
      amount: amount,
      wallet: wallet.name,
      paymentMethod: _selectedType,
      date: date,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : 'Deposit to ${wallet.name}',
      isExpense: false,
      icon: Icons.arrow_downward,
    );

    // 1. Add Income Transaction to shared state
    ref.read(transactionsProvider.notifier).addTransaction(transaction);

    // 2. Update Wallet balance
    ref.read(userWalletsProvider.notifier).updateBalance(wallet.id, amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully added ${_formatRupees(amount)} to ${wallet.name}!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.transactions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(userWalletsProvider);

    if (_selectedWalletId == null && wallets.isNotEmpty) {
      _selectedWalletId = wallets.first.id;
    }

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
          'Add Money',
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
                  Text(
                    'Deposit Funds to Account',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add money to increase your wallet balance and track income transactions in real-time.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AMOUNT TO ADD', style: AppTypography.labelSmall),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.display.copyWith(
                            fontSize: 32,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            prefixText: '₹ ',
                            prefixStyle: AppTypography.display.copyWith(
                              fontSize: 32,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Details Form
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account / Wallet Dropdown
                        Text('Destination Account / Wallet', style: AppTypography.labelSmall),
                        const SizedBox(height: 6),
                        if (wallets.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Primary Account (Default)',
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedWalletId ?? (wallets.isNotEmpty ? wallets.first.id : null),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                            ),
                            items: wallets.map((w) {
                              return DropdownMenuItem(
                                value: w.id,
                                child: Text('${w.name} (${_formatRupees(w.balance)})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedWalletId = val);
                            },
                          ),
                        const SizedBox(height: AppSpacing.m),

                        // Source Selector
                        Text('Income Source', style: AppTypography.labelSmall),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _incomeSources.map((source) {
                              final isSelected = _selectedSource == source;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(source),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedSource = source);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        // Type Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Category / Type',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: _incomeTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.m),

                        // Date Field
                        TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date (YYYY-MM-DD)',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        // Notes
                        TextField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Add transaction details or deposit reference...',
                            prefixIcon: Icon(Icons.note_alt_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: 'Save & Add Money',
                    onPressed: _onSaveAddMoney,
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Cancel',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.wallets);
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
}
