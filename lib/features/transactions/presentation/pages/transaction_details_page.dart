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
import '../../../../core/widgets/mm_text_field.dart';
import '../../../accounts/presentation/providers/user_wallets_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';

/// Page 4 — Transaction Details & Edit Screen
class TransactionDetailsPage extends ConsumerStatefulWidget {
  final String? id;
  final Map<String, dynamic>? initialData;

  const TransactionDetailsPage({
    super.key,
    this.id,
    this.initialData,
  });

  @override
  ConsumerState<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends ConsumerState<TransactionDetailsPage> {
  bool _isExpense = true;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedWallet = '';
  String _source = 'manual'; // 'manual', 'ocr', 'automatic_tracking'
  double? _ocrConfidence;

  String? _amountError;
  String? _categoryError;
  String? _walletError;

  bool _showDuplicateWarning = false;
  TransactionItem? _possibleDuplicate;

  final List<String> _categories = const [
    'Food & Dining',
    'Groceries',
    'Shopping',
    'Bills & Utilities',
    'Housing & Rent',
    'Travel & Commute',
    'Entertainment',
    'Health & Wellness',
    'Investments',
    'Income',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final extra = widget.initialData;

    if (extra != null) {
      _merchantController.text = extra['merchant'] ?? '';
      _amountController.text = extra['amount'] ?? '';
      _categoryController.text = extra['category'] ?? '';
      _dateController.text = extra['date'] ?? '';
      _source = extra['source'] ?? 'manual';
      _ocrConfidence = (extra['ocrConfidence'] as num?)?.toDouble();
    } else if (widget.id != null && widget.id!.isNotEmpty) {
      final transactions = ref.read(transactionsProvider);
      final match = transactions.firstWhere((t) => t.id == widget.id, orElse: () => _emptyTransaction());
      if (match.id == widget.id) {
        _isExpense = match.isExpense;
        _merchantController.text = match.title;
        _amountController.text = match.amount > 0 ? match.amount.toString() : '';
        _categoryController.text = match.category;
        _dateController.text = match.formattedDate;
        _selectedWallet = match.wallet;
        _notesController.text = match.notes ?? '';
        _source = match.source;
        _ocrConfidence = match.ocrConfidence;
      }
    }
  }

  TransactionItem _emptyTransaction() {
    return TransactionItem(
      id: '',
      title: '',
      category: '',
      amount: 0.0,
      wallet: '',
      paymentMethod: '',
      date: DateTime.now(),
      icon: Icons.account_balance_wallet,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _checkForDuplicates() {
    final amt = double.tryParse(_amountController.text.trim());
    final merchant = _merchantController.text.trim().toLowerCase();

    if (amt == null || amt <= 0) return;

    final existingList = ref.read(transactionsProvider);

    final duplicate = existingList.firstWhere(
      (t) => (t.amount - amt).abs() < 1.0 && (merchant.isEmpty || t.title.toLowerCase().contains(merchant)),
      orElse: () => _emptyTransaction(),
    );

    if (duplicate.id.isNotEmpty) {
      setState(() {
        _possibleDuplicate = duplicate;
        _showDuplicateWarning = true;
      });
    }
  }

  void _validateAndProceed() {
    final amountText = _amountController.text.trim();
    final categoryText = _categoryController.text.trim();
    final walletText = _selectedWallet.trim();


    bool valid = true;
    setState(() {
      _amountError = null;
      _categoryError = null;
      _walletError = null;
    });

    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      setState(() => _amountError = 'Amount is required.');
      valid = false;
    }

    if (categoryText.isEmpty) {
      setState(() => _categoryError = 'Please select a category.');
      valid = false;
    }

    final wallets = ref.read(userWalletsProvider);
    final effectiveWallet = walletText.isNotEmpty
        ? walletText
        : (wallets.isNotEmpty ? wallets.first.name : '');

    if (effectiveWallet.isEmpty) {
      setState(() => _walletError = 'Please select an account.');
      valid = false;
    }

    if (!valid) return;

    // Check duplicates if warning not already shown
    if (!_showDuplicateWarning) {
      _checkForDuplicates();
      if (_showDuplicateWarning) return; // Prompt duplicate warning before proceeding
    }

    _navigateToReview(effectiveWallet);
  }

  void _navigateToReview(String walletName) {
    final amount = double.parse(_amountController.text.trim());
    final merchant = _merchantController.text.trim().isEmpty ? 'Expense' : _merchantController.text.trim();
    final category = _categoryController.text.trim();

    context.push(
      AppRoutes.reviewExpense,
      extra: {
        'id': widget.id,
        'title': merchant,
        'amount': amount,
        'category': category,
        'wallet': walletName,
        'isExpense': _isExpense,
        'date': _dateController.text.trim().isEmpty ? DateTime.now().toIso8601String() : _dateController.text.trim(),
        'notes': _notesController.text.trim(),
        'source': _source,
        'ocrConfidence': _ocrConfidence,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(userWalletsProvider);

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
              context.go(AppRoutes.transactions);
            }
          },
        ),
        title: Text(
          'Transaction Details',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source Metadata Badges matching prompt requirements
            Row(
              children: [
                if (_source == 'ocr')
                  const MMStatusChip(
                    label: 'Extracted from receipt',
                    backgroundColor: AppColors.primaryContainer,
                    textColor: AppColors.primary,
                  )
                else if (_source == 'automatic_tracking')
                  const MMStatusChip(
                    label: 'Detected automatically',
                    backgroundColor: AppColors.secondaryContainer,
                    textColor: AppColors.onSecondaryContainer,
                  ),
              ],
            ),
            if (_source != 'manual') const SizedBox(height: AppSpacing.m),

            // Duplicate warning banner if detected
            if (_showDuplicateWarning && _possibleDuplicate != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.tertiaryContainer),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.onTertiaryContainer, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Possible duplicate transaction',
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'An existing transaction with amount ${_possibleDuplicate!.formattedAmount} (${_possibleDuplicate!.title}) was found.',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.onTertiaryContainer),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Expanded(
                          child: MMButton(
                            label: 'Review Existing',
                            type: MMButtonType.secondary,
                            onPressed: () {
                              context.push('/transactions/${_possibleDuplicate!.id}');
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: MMButton(
                            label: 'Save Anyway',
                            onPressed: () {
                              final wallets = ref.read(userWalletsProvider);
                              final effWallet = _selectedWallet.isNotEmpty
                                  ? _selectedWallet
                                  : (wallets.isNotEmpty ? wallets.first.name : 'Primary Account');
                              _navigateToReview(effWallet);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
            ],

            // Transaction Type Selector (Expense vs Income)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isExpense = true),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isExpense ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.m),
                        border: Border.all(color: _isExpense ? AppColors.primary : AppColors.outlineVariant),
                      ),
                      child: Center(
                        child: Text(
                          'Expense',
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isExpense ? AppColors.primary : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isExpense = false),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isExpense ? AppColors.secondaryContainer : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.m),
                        border: Border.all(color: !_isExpense ? AppColors.onSecondaryContainer : AppColors.outlineVariant),
                      ),
                      child: Center(
                        child: Text(
                          'Income',
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: !_isExpense ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.l),

            // Amount Input (Empty by default, ZERO fake pre-filled values!)
            MMTextField(
              label: 'Amount (₹)',
              hint: '[ Enter amount ]',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: _amountController,
              errorText: _amountError,
              onChanged: (val) {
                if (_amountError != null) setState(() => _amountError = null);
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Merchant / Title Input
            MMTextField(
              label: 'Merchant / Description',
              hint: '[ Enter merchant or description ]',
              controller: _merchantController,
            ),

            const SizedBox(height: AppSpacing.m),

            // Category Selector
            Text('Category', style: AppTypography.labelSmall),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _categoryController.text.isNotEmpty ? _categoryController.text : null,
              hint: const Text('[ Select category ]'),
              decoration: InputDecoration(
                fillColor: AppColors.surfaceContainerLow,
                filled: true,
                errorText: _categoryError,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.borderXs,
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _categoryController.text = val;
                    _categoryError = null;
                  });
                }
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Account / Wallet Selector
            Text('Account / Wallet', style: AppTypography.labelSmall),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _selectedWallet.isNotEmpty
                  ? _selectedWallet
                  : (wallets.isNotEmpty ? wallets.first.name : null),
              hint: const Text('[ Select account / wallet ]'),
              decoration: InputDecoration(
                fillColor: AppColors.surfaceContainerLow,
                filled: true,
                errorText: _walletError,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.borderXs,
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              items: (wallets.isNotEmpty
                      ? wallets.map((w) => w.name).toList()
                      : ['HDFC Bank Account', 'UPI Account', 'Cash'])
                  .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedWallet = val;
                    _walletError = null;
                  });
                }
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Date Selector
            MMTextField(
              label: 'Date',
              hint: '[ Select date e.g. 2026-08-16 ]',
              controller: _dateController,
            ),

            const SizedBox(height: AppSpacing.m),

            // Notes Input
            MMTextField(
              label: 'Notes (Optional)',
              hint: '[ Optional notes ]',
              controller: _notesController,
            ),

            const SizedBox(height: AppSpacing.stackLg),

            // Proceed to Confirmation CTA
            MMButton(
              label: 'Review Transaction',
              onPressed: _validateAndProceed,
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
