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
import '../../../../core/widgets/mm_section_header.dart';
import '../../../../core/widgets/mm_text_field.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';
import '../../../accounts/presentation/providers/user_wallets_provider.dart';
import '../../../accounts/presentation/providers/tracking_settings_provider.dart';
import '../widgets/receipt_scanner_frame.dart';
import '../widgets/payment_method_tile.dart';
import '../widgets/wallet_card.dart';
import '../../../../core/widgets/mm_ai_insight_card.dart';
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../../core/services/web_ocr_service.dart';
import '../widgets/transactions_hero_summary_card.dart';
import '../widgets/transactions_search_filter_bar.dart';
import '../widgets/transaction_group_section.dart';
import '../widgets/transactions_empty_state.dart';

/// Stitch Screen: MoneyMateX Transactions Screen (bd0569afc65c4931b8cdb0bbe1abb907)
class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Expense',
    'Income',
    'Food & Dining',
    'Shopping',
    'Bills & Utilities',
    'Travel',
    'Investments',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    // Calculate Inflow & Outflow totals and transaction counts
    final incomeItems = transactions.where((t) => !t.isExpense).toList();
    final expenseItems = transactions.where((t) => t.isExpense).toList();
    final double inflow = incomeItems.fold(0.0, (sum, item) => sum + item.amount);
    final double outflow = expenseItems.fold(0.0, (sum, item) => sum + item.amount);

    // Filter transactions based on category and search query
    final query = _searchController.text.trim().toLowerCase();
    final filtered = transactions.where((t) {
      if (_selectedCategory == 'Expense' && !t.isExpense) return false;
      if (_selectedCategory == 'Income' && t.isExpense) return false;
      if (_selectedCategory != 'All' &&
          _selectedCategory != 'Expense' &&
          _selectedCategory != 'Income') {
        if (!t.category.toLowerCase().contains(_selectedCategory.toLowerCase())) {
          return false;
        }
      }
      if (query.isNotEmpty) {
        final matchesTitle = t.title.toLowerCase().contains(query);
        final matchesCategory = t.category.toLowerCase().contains(query);
        final matchesAmount = t.formattedAmount.contains(query);
        if (!matchesTitle && !matchesCategory && !matchesAmount) return false;
      }
      return true;
    }).toList();

    // Chronological Date Grouping
    final now = DateTime.now();
    const todayKey = 'Today';
    const yesterdayKey = 'Yesterday';
    const thisWeekKey = 'This Week';
    const earlierKey = 'Earlier';

    final Map<String, List<TransactionItem>> grouped = {
      todayKey: [],
      yesterdayKey: [],
      thisWeekKey: [],
      earlierKey: [],
    };

    for (final item in filtered) {
      final date = item.date;
      final diffDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(date.year, date.month, date.day))
          .inDays;

      if (diffDays == 0) {
        grouped[todayKey]!.add(item);
      } else if (diffDays == 1) {
        grouped[yesterdayKey]!.add(item);
      } else if (diffDays > 1 && diffDays <= 7) {
        grouped[thisWeekKey]!.add(item);
      } else {
        grouped[earlierKey]!.add(item);
      }
    }

    final bool isFilterActive = _selectedCategory != 'All' || query.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Transactions & Activity',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${transactions.length} total transaction${transactions.length == 1 ? "" : "s"}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined, color: AppColors.primary),
            tooltip: 'Scan Receipt',
            onPressed: () => context.go(AppRoutes.scanReceipt),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Expense',
            onPressed: () => context.go(AppRoutes.addExpense),
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
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Monthly Cash Flow Summary
                  TransactionsHeroSummaryCard(
                    inflow: inflow,
                    outflow: outflow,
                    inflowCount: incomeItems.length,
                    outflowCount: expenseItems.length,
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 2. Search Field & Category Filters
                  TransactionsSearchFilterBar(
                    searchController: _searchController,
                    selectedCategory: _selectedCategory,
                    categories: _categories,
                    onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                    onClearSearch: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 3. Chronological Date-Grouped Transaction List or Empty State
                  if (filtered.isEmpty)
                    TransactionsEmptyState(
                      isFiltered: isFilterActive,
                      onClearFilters: () {
                        setState(() {
                          _selectedCategory = 'All';
                          _searchController.clear();
                        });
                      },
                      onAddExpense: () => context.go(AppRoutes.addExpense),
                      onScanReceipt: () => context.go(AppRoutes.scanReceipt),
                    )
                  else ...[
                    if (grouped[todayKey]!.isNotEmpty)
                      TransactionGroupSection(
                        sectionTitle: 'Today',
                        items: grouped[todayKey]!,
                        onItemTap: (tx) => context.go(
                          AppRoutes.transactionDetails.replaceAll(':id', tx.id),
                        ),
                      ),
                    if (grouped[yesterdayKey]!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.m),
                      TransactionGroupSection(
                        sectionTitle: 'Yesterday',
                        items: grouped[yesterdayKey]!,
                        onItemTap: (tx) => context.go(
                          AppRoutes.transactionDetails.replaceAll(':id', tx.id),
                        ),
                      ),
                    ],
                    if (grouped[thisWeekKey]!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.m),
                      TransactionGroupSection(
                        sectionTitle: 'This Week',
                        items: grouped[thisWeekKey]!,
                        onItemTap: (tx) => context.go(
                          AppRoutes.transactionDetails.replaceAll(':id', tx.id),
                        ),
                      ),
                    ],
                    if (grouped[earlierKey]!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.m),
                      TransactionGroupSection(
                        sectionTitle: 'Earlier',
                        items: grouped[earlierKey]!,
                        onItemTap: (tx) => context.go(
                          AppRoutes.transactionDetails.replaceAll(':id', tx.id),
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Transaction Details Screen (1c6466e3ad3b406cbee38fae4a622b4a)
class TransactionDetailsPage extends ConsumerWidget {
  final String id;
  const TransactionDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final item = transactions.firstWhere(
      (t) => t.id == id,
      orElse: () => TransactionItem(
        id: id,
        title: 'Transaction Details',
        category: 'General',
        amount: 0,
        wallet: 'Default Wallet',
        paymentMethod: 'UPI',
        date: DateTime.now(),
        icon: Icons.receipt_long,
        isExpense: true,
      ),
    );

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
              context.go(AppRoutes.transactions);
            }
          },
        ),
        title: Text(
          'Transaction Details',
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
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.isExpense ? AppColors.error.withValues(alpha: 0.1) : const Color(0xFFDCFCE7),
                          ),
                          child: Icon(
                            item.icon,
                            size: 32,
                            color: item.isExpense ? AppColors.error : const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          item.title,
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.isExpense ? "-" : "+"}₹${item.amount.toInt()}',
                          style: AppTypography.display.copyWith(
                            color: item.isExpense ? AppColors.onSurface : const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackLg),
                        const Divider(color: AppColors.outlineVariant),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Category', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                            Text(item.category, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payment Method / Wallet', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                            Text(item.wallet, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date & Time', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                            Text('${item.formattedDate} • ${item.formattedTime}', style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (item.notes != null && item.notes!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.m),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Notes', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                              Text(item.notes!, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                        if (item.receiptPath != null && item.receiptPath!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.m),
                          const Divider(color: AppColors.outlineVariant),
                          const SizedBox(height: AppSpacing.m),
                          Text('Attached Receipt', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Image.network(
                              item.receiptPath!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.receipt_long, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text('Receipt Image Attached', style: AppTypography.bodyMedium),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  MMButton(
                    label: 'Delete Transaction',
                    type: MMButtonType.secondary,
                    fullWidth: true,
                    onPressed: () {
                      ref.read(transactionsProvider.notifier).deleteTransaction(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction deleted successfully'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.transactions);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Add Expense Screen (4403a1a291be467993075f2d047b048a)
class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _transactionType = 'Expense';
  String _selectedCategory = 'Food & Dining';
  String _selectedWallet = 'HDFC Priority Savings';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRecurring = false;

  final List<String> _categories = const [
    'Food & Dining',
    'Shopping & Lifestyle',
    'Bills & Utilities',
    'Housing & Rent',
    'Travel & Commute',
    'Entertainment',
    'Health & Wellness',
    'Other Expense',
  ];

  final List<String> _wallets = const [
    'HDFC Priority Savings',
    'ICICI Savings Reserve',
    'HDFC Credit Card',
    'Cash Vault',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitExpense() {
    final rawAmount = _amountController.text.trim();
    final double? parsedAmount = double.tryParse(rawAmount.replaceAll(',', ''));

    if (rawAmount.isEmpty || parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid expense amount.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedWallet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wallet or payment method.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final title = _merchantController.text.trim().isNotEmpty
        ? _merchantController.text.trim()
        : '$_selectedCategory Expense';

    final newItem = TransactionItem(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: _selectedCategory,
      amount: parsedAmount,
      wallet: _selectedWallet,
      paymentMethod: _selectedWallet,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      isExpense: _transactionType == 'Expense',
      icon: TransactionsNotifier.getCategoryIcon(_selectedCategory),
    );

    ref.read(transactionsProvider.notifier).addTransaction(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expense transaction of ${newItem.formattedAmount} saved successfully!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    context.go(AppRoutes.transactions);
  }

  Widget _buildTypePill(String type, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _transactionType = type),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          type,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
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
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.transactions);
            }
          },
        ),
        title: Text(
          'Add Expense',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            tooltip: 'Scan Receipt with OCR',
            onPressed: () => context.go(AppRoutes.scanReceipt),
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
                  // Section 1: Transaction Type Selector & Hero Amount Entry Box
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTypePill('Expense', _transactionType == 'Expense'),
                            const SizedBox(width: 8),
                            _buildTypePill('Income', _transactionType == 'Income'),
                            const SizedBox(width: 8),
                            _buildTypePill('Transfer', _transactionType == 'Transfer'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          'ENTER AMOUNT',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹',
                              style: AppTypography.display.copyWith(
                                color: AppColors.primary,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: AppTypography.display.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0.00',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Form Details Entry Card
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
                        Text('Merchant / Payee Name', style: AppTypography.labelSmall),
                        const SizedBox(height: 4),
                        MMTextField(
                          label: '',
                          hint: 'e.g. Starbucks, Amazon, Uber',
                          controller: _merchantController,
                        ),
                        const SizedBox(height: AppSpacing.m),

                        Text('Select Category', style: AppTypography.labelSmall),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: MMCategoryChip(
                                  label: cat,
                                  isSelected: _selectedCategory == cat,
                                  onSelected: () => setState(() => _selectedCategory = cat),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        MMDropdownField<String>(
                          label: 'Payment Method / Wallet',
                          value: _selectedWallet,
                          items: _wallets.map((w) {
                            return DropdownMenuItem(value: w, child: Text(w));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedWallet = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.m),

                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedDate = picked);
                                  }
                                },
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(AppRadius.xs),
                                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime,
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedTime = picked);
                                  }
                                },
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(AppRadius.xs),
                                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime.format(context),
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),

                        Text('Notes & Description', style: AppTypography.labelSmall),
                        const SizedBox(height: 4),
                        MMTextField(
                          label: '',
                          hint: 'Optional notes (e.g. Coffee with team)',
                          controller: _notesController,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Receipt Attachment Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.receipt_long, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Attach Receipt / Invoice', style: AppTypography.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Scan with camera or upload image', style: AppTypography.labelSmall.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                          onPressed: () => context.go(AppRoutes.scanReceipt),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 4: Recurring Transaction Checkbox Row
                  Row(
                    children: [
                      Checkbox(
                        value: _isRecurring,
                        onChanged: (val) => setState(() => _isRecurring = val ?? false),
                        activeColor: AppColors.primary,
                      ),
                      Text('Mark as Recurring Expense (Monthly)', style: AppTypography.bodyMedium),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: Budget Impact Indicator Card (Stitch Screen #25)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Icon(Icons.pie_chart_outline, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_selectedCategory Budget',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹4,200 / ₹8,000 used',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 80,
                          child: MMProgressBar(
                            progress: 0.52,
                            height: 6,
                            color: AppColors.primary,
                            backgroundColor: AppColors.surfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: Save & Cancel Buttons
                  MMButton(
                    label: 'Save Expense Transaction',
                    onPressed: _submitExpense,
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
                        context.go(AppRoutes.transactions);
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

/// Stitch Screen: MoneyMateX Scan Receipt Screen (View A) (ca85f8bb2c654498a70de0a6351736fc)
class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  bool _flashEnabled = false;
  String _scanMode = 'Single Receipt';
  String? _selectedImageDataUrl;
  bool _isProcessingOcr = false;
  OcrResultData? _ocrResult;

  final List<String> _scanModes = const ['Single Receipt', 'Multi-Item Bill', 'PDF Invoice'];

  Future<void> _pickAndProcessImage({bool isCamera = false}) async {
    try {
      final imageDataUrl = await WebOcrService.pickReceiptImage(isCamera: isCamera);
      if (imageDataUrl == null || imageDataUrl.isEmpty) {
        return;
      }

      setState(() {
        _selectedImageDataUrl = imageDataUrl;
        _isProcessingOcr = true;
      });

      final ocrData = await WebOcrService.processReceiptImage(imageDataUrl);

      setState(() {
        _ocrResult = ocrData;
        _isProcessingOcr = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ocrData.merchant.isNotEmpty
                  ? 'Receipt text processed! Merchant: "${ocrData.merchant}"'
                  : 'Receipt image loaded. Tap Continue to review extracted details.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingOcr = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _continueToReview() {
    final Map<String, dynamic> data = _ocrResult?.toMap() ?? {
      'imageDataUrl': _selectedImageDataUrl,
      'merchant': '',
      'amount': '',
      'category': 'Food & Dining',
      'paymentMethod': 'UPI / GPay',
      'items': <String>[],
    };

    if (data['imageDataUrl'] == null && _selectedImageDataUrl != null) {
      data['imageDataUrl'] = _selectedImageDataUrl;
    }

    context.go(AppRoutes.reviewExpense, extra: data);
  }

  @override
  Widget build(BuildContext context) {
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
              context.go(AppRoutes.addExpense);
            }
          },
        ),
        title: Text(
          'Scan Receipt',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _flashEnabled ? Icons.flash_on : Icons.flash_off,
              color: AppColors.primary,
            ),
            tooltip: 'Toggle Flash',
            onPressed: () => setState(() => _flashEnabled = !_flashEnabled),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.primary),
            tooltip: 'Scanning Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Receipt Scanning Guide'),
                  content: const Text(
                    '• Tap Take Photo or Choose File to upload a real receipt.\n'
                    '• Tesseract.js runs Web OCR directly in your browser.\n'
                    '• Extracted fields (Merchant, Amount, Date) will be loaded onto the Review screen.\n'
                    '• Every field remains 100% editable by you.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mode Selector Chips Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _scanModes.map((mode) {
                        final isSelected = _scanMode == mode;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: MMCategoryChip(
                            label: mode,
                            isSelected: isSelected,
                            onSelected: () => setState(() => _scanMode = mode),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.m),

                  // Smart Scanning AI Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.auto_awesome, color: AppColors.onPrimaryContainer, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '✨ Web AI Receipt Scanner',
                                    style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  if (_selectedImageDataUrl != null)
                                    const MMStatusChip(
                                      label: 'Image Ready',
                                      backgroundColor: Color(0xFFE8F5E9),
                                      textColor: Color(0xFF2E7D32),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Upload or take photo of a receipt. MoneyMateX runs Web OCR to extract Merchant, Amount, Date & Category.',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Viewfinder Frame displaying actual selected image
                  Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: _selectedImageDataUrl != null ? const Color(0xFF10B981) : AppColors.outlineVariant,
                        width: _selectedImageDataUrl != null ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isProcessingOcr) ...[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: AppColors.secondary),
                              const SizedBox(height: 16),
                              Text(
                                'Running Web OCR on receipt image...',
                                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                              ),
                            ],
                          )
                        ] else if (_selectedImageDataUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            child: Image.network(
                              _selectedImageDataUrl!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.receipt_long, size: 64, color: Colors.white54),
                                  const SizedBox(height: 8),
                                  Text('Receipt Image Loaded', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          const ReceiptScannerFrame(
                            tipText: 'Tap Camera or Upload below\nAI will extract merchant, date & total',
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Camera & Gallery Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Upload from Device / Gallery Button
                      Column(
                        children: [
                          IconButton.filledTonal(
                            iconSize: 28,
                            icon: const Icon(Icons.photo_library_outlined),
                            tooltip: 'Upload Receipt Image from Device',
                            onPressed: () => _pickAndProcessImage(isCamera: false),
                          ),
                          const SizedBox(height: 4),
                          Text('Choose File', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                        ],
                      ),

                      // Main Capture Shutter Button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => _pickAndProcessImage(isCamera: true),
                            child: Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 3),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Take Photo', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                        ],
                      ),

                      // Advanced Scan Shortcut
                      Column(
                        children: [
                          IconButton.filledTonal(
                            iconSize: 28,
                            icon: const Icon(Icons.crop_free),
                            tooltip: 'Advanced Crop',
                            onPressed: () => context.go(AppRoutes.scanReceiptAdvanced),
                          ),
                          const SizedBox(height: 4),
                          Text('Crop Frame', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Action Buttons
                  if (_selectedImageDataUrl != null) ...[
                    MMButton(
                      label: 'Continue to Review Expense',
                      onPressed: _continueToReview,
                      type: MMButtonType.primary,
                      fullWidth: true,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    MMButton(
                      label: 'Pick Another Image',
                      onPressed: () => _pickAndProcessImage(isCamera: false),
                      type: MMButtonType.secondary,
                      fullWidth: true,
                    ),
                  ] else ...[
                    MMButton(
                      label: 'Upload Receipt Image',
                      onPressed: () => _pickAndProcessImage(isCamera: false),
                      type: MMButtonType.primary,
                      fullWidth: true,
                    ),
                  ],
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

/// Stitch Screen: MoneyMateX Scan Receipt Screen (View B) (656215ccf46f4a0b99092d1521e4e504)
class ScanReceiptAdvancedPage extends StatefulWidget {
  const ScanReceiptAdvancedPage({super.key});

  @override
  State<ScanReceiptAdvancedPage> createState() => _ScanReceiptAdvancedPageState();
}

class _ScanReceiptAdvancedPageState extends State<ScanReceiptAdvancedPage> {
  bool _isAutoCropEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.scanReceipt);
            }
          },
        ),
        title: Text(
          'Crop & Review Receipt',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isAutoCropEnabled ? Icons.crop_free : Icons.crop,
              color: AppColors.secondary,
            ),
            tooltip: 'Auto-Crop Adjust',
            onPressed: () => setState(() => _isAutoCropEnabled = !_isAutoCropEnabled),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Retake Photo',
            onPressed: () => context.go(AppRoutes.scanReceipt),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
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
                  // Section 1: Captured Receipt Crop & Highlight Frame
                  Container(
                    width: double.infinity,
                    height: 420,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: _isAutoCropEnabled ? AppColors.secondary : AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Receipt Paper Mockup
                        Center(
                          child: Container(
                            width: 260,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Merchant Header Box (Highlighted)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.aiContainer,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.aiAccent, width: 1),
                                  ),
                                  child: Text(
                                    'STARBUCKS COFFEE',
                                    style: AppTypography.headlineMedium.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Date: 12 Aug 2026, 04:15 PM', style: AppTypography.labelSmall.copyWith(color: Colors.black54, fontSize: 10)),
                                Text('Txn ID: #STB-984210', style: AppTypography.labelSmall.copyWith(color: Colors.black54, fontSize: 10)),
                                const Divider(height: 16, color: Colors.black12),
                                Text('1x Caffe Latte (Venti)   ₹380.00', style: AppTypography.bodyMedium.copyWith(color: Colors.black87, fontSize: 11)),
                                Text('1x Butter Croissant     ₹70.00', style: AppTypography.bodyMedium.copyWith(color: Colors.black87, fontSize: 11)),
                                const Divider(height: 16, color: Colors.black12),

                                // Amount Total Box (Green Highlight)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF2E7D32), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('TOTAL PAID:', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
                                      Text('₹450.00', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Corner Crop Handles Overlay
                        const Positioned(
                          top: 10,
                          left: 10,
                          child: CircleAvatar(radius: 10, backgroundColor: AppColors.secondary, child: Icon(Icons.crop_free, size: 12, color: Colors.black)),
                        ),
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(radius: 10, backgroundColor: AppColors.secondary, child: Icon(Icons.crop_free, size: 12, color: Colors.black)),
                        ),
                        const Positioned(
                          bottom: 10,
                          left: 10,
                          child: CircleAvatar(radius: 10, backgroundColor: AppColors.secondary, child: Icon(Icons.crop_free, size: 12, color: Colors.black)),
                        ),
                        const Positioned(
                          bottom: 10,
                          right: 10,
                          child: CircleAvatar(radius: 10, backgroundColor: AppColors.secondary, child: Icon(Icons.crop_free, size: 12, color: Colors.black)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: K2i AI Optical Pre-Extracted Data Card
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
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.aiAccent, size: 20),
                            const SizedBox(width: 8),
                            Text('K2i AI Optical Extraction', style: AppTypography.headlineMedium.copyWith(fontSize: 16)),
                            const Spacer(),
                            const MMStatusChip(
                              label: '98% Confidence',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        _buildExtractedFieldRow('Merchant', 'Starbucks Coffee'),
                        const Divider(height: 16, color: AppColors.outlineVariant),
                        _buildExtractedFieldRow('Date & Time', '12 Aug 2026, 04:15 PM'),
                        const Divider(height: 16, color: AppColors.outlineVariant),
                        _buildExtractedFieldRow('Suggested Category', 'Food & Dining'),
                        const Divider(height: 16, color: AppColors.outlineVariant),
                        _buildExtractedFieldRow('Total Amount', '₹450.00', isAmount: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Action Buttons
                  MMButton(
                    label: 'Extract & Confirm Expense',
                    onPressed: () => context.go(AppRoutes.scanResult),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Retake Photo',
                    onPressed: () => context.go(AppRoutes.scanReceipt),
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

  Widget _buildExtractedFieldRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.labelSmall),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isAmount ? AppColors.primary : AppColors.onBackground,
          ),
        ),
      ],
    );
  }
}

/// Stitch Screen: MoneyMateX Review Expense Screen (25a88ab65be140529a5a5d4a08416ddf)
class ReviewExpensePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;
  const ReviewExpensePage({super.key, this.initialData});

  @override
  ConsumerState<ReviewExpensePage> createState() => _ReviewExpensePageState();
}

class _ReviewExpensePageState extends ConsumerState<ReviewExpensePage> {
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;

  String _selectedCategory = 'Food & Dining';
  String _selectedWallet = 'HDFC Priority Savings';
  final DateTime _selectedDate = DateTime.now();
  final TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _categories = const [
    'Food & Dining',
    'Shopping',
    'Bills & Utilities',
    'Travel',
    'Housing & Rent',
    'Entertainment',
    'Health & Wellness',
    'Other Expense',
  ];

  final List<String> _wallets = const [
    'HDFC Priority Savings',
    'ICICI Savings Reserve',
    'HDFC Credit Card',
    'UPI / GPay',
    'Cash Vault',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _merchantController = TextEditingController(
      text: data?['merchant']?.toString() ?? '',
    );
    _amountController = TextEditingController(
      text: data?['amount']?.toString() ?? '',
    );
    if (data?['category'] != null) {
      _selectedCategory = data!['category'].toString();
    }
    if (data?['wallet'] != null) {
      _selectedWallet = data!['wallet'].toString();
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _confirmAndAddExpense() {
    final rawAmount = _amountController.text.trim();
    final double? parsedAmount = double.tryParse(rawAmount.replaceAll(',', ''));
    final merchantName = _merchantController.text.trim();

    if (rawAmount.isEmpty || parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid expense amount.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (merchantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the merchant / store name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final String? imageDataUrl = widget.initialData?['imageDataUrl']?.toString();

    final newItem = TransactionItem(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: merchantName,
      category: _selectedCategory,
      amount: parsedAmount,
      wallet: _selectedWallet,
      paymentMethod: _selectedWallet,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      notes: 'Scanned Receipt Expense',
      isExpense: true,
      receiptPath: imageDataUrl,
      icon: TransactionsNotifier.getCategoryIcon(_selectedCategory),
    );

    ref.read(transactionsProvider.notifier).addTransaction(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expense transaction of ${newItem.formattedAmount} for $merchantName saved successfully!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    context.go(AppRoutes.transactions);
  }

  @override
  Widget build(BuildContext context) {
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
              context.go(AppRoutes.scanReceipt);
            }
          },
        ),
        title: Text(
          'Review Expense',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'Rescan Receipt',
            onPressed: () => context.go(AppRoutes.scanReceipt),
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
                  // Extraction Status & Confidence Banner Card
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EXTRACTION COMPLETED',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const MMStatusChip(
                              label: '98% Confidence',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            if (widget.initialData?['imageDataUrl'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                child: Image.network(
                                  widget.initialData!['imageDataUrl'].toString(),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => Container(
                                    width: 48,
                                    height: 48,
                                    color: AppColors.aiContainer,
                                    child: const Icon(Icons.receipt_long, color: AppColors.aiAccent, size: 28),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.aiContainer,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Icon(Icons.receipt_long, color: AppColors.aiAccent, size: 28),
                              ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _merchantController.text.isNotEmpty
                                        ? '${_merchantController.text.toLowerCase().replaceAll(" ", "_")}_receipt.jpg'
                                        : 'user_uploaded_receipt.jpg',
                                    style: AppTypography.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _merchantController.text.isNotEmpty
                                        ? 'Captured receipt • OCR Parsed'
                                        : 'Captured receipt • [Merchant Not Detected - Enter below]',
                                    style: AppTypography.labelSmall.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Extracted & Editable Fields Form Card
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
                        Text('Merchant / Store Name', style: AppTypography.labelSmall),
                        const SizedBox(height: 4),
                        MMTextField(
                          label: '',
                          hint: 'Enter merchant name (e.g. Test Store)',
                          controller: _merchantController,
                        ),
                        const SizedBox(height: AppSpacing.m),

                        Text('Extracted Total Amount (₹)', style: AppTypography.labelSmall),
                        const SizedBox(height: 4),
                        MMTextField(
                          label: '',
                          hint: 'Enter amount (e.g. 500.00)',
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        Text('Select Category', style: AppTypography.labelSmall),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((c) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: MMCategoryChip(
                                  label: c,
                                  isSelected: _selectedCategory == c,
                                  onSelected: () => setState(() => _selectedCategory = c),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        MMDropdownField<String>(
                          label: 'Payment Wallet / Method',
                          value: _selectedWallet,
                          items: _wallets.map((w) {
                            return DropdownMenuItem(value: w, child: Text(w));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedWallet = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Itemized Line Items Matrix
                  const MMSectionHeader(
                    title: 'Detected Items & Summary',
                    subtitle: 'Review itemized total before saving',
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _merchantController.text.isNotEmpty
                                    ? _merchantController.text
                                    : 'Scanned Item',
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _amountController.text.isNotEmpty
                                    ? '₹${_amountController.text}'
                                    : '₹0.00',
                                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.outlineVariant),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tax / Charges (Included)', style: AppTypography.labelSmall),
                              Text('Auto-calculated', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // AI Budget Impact Insight Card
                  MMAIInsightCard(
                    title: 'Budget Impact Analysis',
                    description: 'Adding this expense will update your $_selectedCategory budget and real-time dashboard totals.',
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Action Buttons
                  MMButton(
                    label: 'Confirm & Add Expense',
                    onPressed: _confirmAndAddExpense,
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Retake Scan',
                    onPressed: () => context.go(AppRoutes.scanReceipt),
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

typedef ScanResultPage = ReviewExpensePage;

/// Stitch Screen: MoneyMateX Receipt Scan Result Screen (View B) (bb2e30310535400ea3aacf9074338ea2)
class ScanResultSummaryPage extends StatefulWidget {
  const ScanResultSummaryPage({super.key});

  @override
  State<ScanResultSummaryPage> createState() => _ScanResultSummaryPageState();
}

class _ScanResultSummaryPageState extends State<ScanResultSummaryPage> {
  @override
  Widget build(BuildContext context) {
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
              context.go(AppRoutes.scanResult);
            }
          },
        ),
        title: Text(
          'Receipt Analysis Summary',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
            tooltip: 'View Result A',
            onPressed: () => context.go(AppRoutes.scanResult),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'Rescan Receipt',
            onPressed: () => context.go(AppRoutes.scanReceipt),
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
                  // Section 1: Scan Analytics Hero Card
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EXTRACTION ANALYTICS SUMMARY',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const MMStatusChip(
                              label: 'OCR Verified',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '₹450.00',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Starbucks Coffee • 12 Aug 2026, 04:15 PM',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TAX / GST (5%)', style: AppTypography.labelSmall),
                                  Text('₹22.50 (Inc.)', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ),
                            Container(height: 32, width: 1, color: AppColors.outlineVariant),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PAYMENT SOURCE', style: AppTypography.labelSmall),
                                  Text('HDFC Priority', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Category Budget Impact Card
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('FOOD & DINING BUDGET IMPACT', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                            const MMStatusChip(
                              label: '121.4% Spent',
                              backgroundColor: AppColors.errorContainer,
                              textColor: AppColors.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Category Target Ceiling', style: AppTypography.labelSmall),
                            Text('₹35,000 / mo', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('New Total Spent', style: AppTypography.labelSmall),
                            Text('₹42,500 (+₹450)', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const MMProgressBar(progress: 1.0, height: 8),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Itemized Line Items & Weights
                  const MMSectionHeader(
                    title: 'Itemized Breakdown & Share',
                    subtitle: 'Relative item proportions',
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('1x Caffe Latte (Venti)', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                  Text('84.4% of total receipt', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                                ],
                              ),
                              Text('₹380.00', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.outlineVariant),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('1x Butter Croissant', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                  Text('15.6% of total receipt', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                                ],
                              ),
                              Text('₹70.00', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 4: K2i AI Advisory Card
                  MMAIInsightCard(
                    title: 'Food & Dining Ceiling Advisory',
                    description: 'This ₹450 expense pushes Food & Dining 21.4% over budget. Enable automatic UPI tracking to set micro-savings rules.',
                    actionLabel: 'Setup UPI Auto-Tracking',
                    onAction: () => context.go(AppRoutes.upiSetup),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: Action Buttons
                  MMButton(
                    label: 'Confirm & Save Expense',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Scanned receipt transaction confirmed!')),
                      );
                      context.go(AppRoutes.transactions);
                    },
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Setup UPI Automatic Tracking',
                    onPressed: () => context.go(AppRoutes.upiSetup),
                    type: MMButtonType.secondary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Retake Receipt Photo',
                    onPressed: () => context.go(AppRoutes.scanReceipt),
                    type: MMButtonType.text,
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

/// Stitch Screen: MoneyMateX UPI Automatic Tracking Setup (afce4e7c66354d1ea25218c049885689)
class UpiSetupPage extends StatefulWidget {
  const UpiSetupPage({super.key});

  @override
  State<UpiSetupPage> createState() => _UpiSetupPageState();
}

class _UpiSetupPageState extends State<UpiSetupPage> {
  bool _isUpiTrackingEnabled = false;
  bool _isNotificationPermissionGranted = true;
  bool _trackGPay = true;
  bool _trackPhonePe = true;
  bool _trackPaytm = true;
  bool _trackBhim = true;
  bool _autoCategorizeAI = true;
  String _selectedDefaultWallet = 'HDFC Priority Savings';

  final List<String> _wallets = const [
    'HDFC Priority Savings',
    'ICICI Savings Reserve',
    'HDFC Credit Card',
    'Cash Vault',
  ];

  @override
  Widget build(BuildContext context) {
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
              context.go(AppRoutes.transactions);
            }
          },
        ),
        title: Text(
          'UPI Automatic Tracking',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.primary),
            tooltip: 'Privacy & Security Info',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All UPI parsing happens 100% on-device. No data leaves your phone.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
                  // Section 1: Hero Automatic Tracking Toggle Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: _isUpiTrackingEnabled
                            ? AppColors.primaryContainer
                            : AppColors.outlineVariant,
                        width: _isUpiTrackingEnabled ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AUTOMATIC EXPENSE DETECTION',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            MMStatusChip(
                              label: _isUpiTrackingEnabled ? 'Active' : 'Disabled',
                              backgroundColor: _isUpiTrackingEnabled
                                  ? const Color(0xFFE8F5E9)
                                  : AppColors.secondaryContainer,
                              textColor: _isUpiTrackingEnabled
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.onSecondaryContainer,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Zero-Effort Auto-Tracking',
                                style: AppTypography.headlineLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            Switch(
                              value: _isUpiTrackingEnabled,
                              onChanged: (val) => setState(() => _isUpiTrackingEnabled = val),
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MoneyMateX reads SMS bank alerts and UPI payment notifications automatically to log and categorize transactions instantly.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Setup Steps Configuration Matrix
                  const MMSectionHeader(
                    title: 'Setup Configuration Steps',
                    subtitle: 'Configure permissions & app targets',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step 1: Notification Permission
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notification Listener Access',
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Allows reading payment SMS alerts from bank & UPI apps',
                                    style: AppTypography.labelSmall.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isNotificationPermissionGranted,
                              onChanged: (val) => setState(() => _isNotificationPermissionGranted = val),
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),

                        const Divider(height: 28, color: AppColors.outlineVariant),

                        // Step 2: Target Payment Apps Selection
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '2',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Supported Payment & UPI Apps',
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Select which financial apps to monitor',
                                    style: AppTypography.labelSmall.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        _buildAppToggleRow(
                          'Google Pay (GPay)',
                          'Monitor GPay transaction SMS & pushes',
                          Icons.account_balance_wallet_outlined,
                          _trackGPay,
                          (v) => setState(() => _trackGPay = v),
                        ),
                        _buildAppToggleRow(
                          'PhonePe UPI',
                          'Track PhonePe payment notifications',
                          Icons.send_to_mobile_outlined,
                          _trackPhonePe,
                          (v) => setState(() => _trackPhonePe = v),
                        ),
                        _buildAppToggleRow(
                          'Paytm Payments',
                          'Capture Paytm Wallet & Bank alerts',
                          Icons.payment_outlined,
                          _trackPaytm,
                          (v) => setState(() => _trackPaytm = v),
                        ),
                        _buildAppToggleRow(
                          'BHIM & Bank SMS',
                          'Direct bank SMS debit/credit tracking',
                          Icons.receipt_long_outlined,
                          _trackBhim,
                          (v) => setState(() => _trackBhim = v),
                        ),

                        const Divider(height: 28, color: AppColors.outlineVariant),

                        // Step 3: Default Wallet & AI Categorization
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '3',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Default Account & Intelligence',
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Set target wallet & AI auto-categorization',
                                    style: AppTypography.labelSmall.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMDropdownField<String>(
                          label: 'Default Deposit Wallet',
                          value: _selectedDefaultWallet,
                          items: _wallets.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDefaultWallet = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auto-Categorize with K2i AI',
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Smartly tag Swiggy, Uber, Amazon & merchants',
                                    style: AppTypography.labelSmall.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _autoCategorizeAI,
                              onChanged: (val) => setState(() => _autoCategorizeAI = val),
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Privacy & Security Assurance Card
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
                        Row(
                          children: [
                            const Icon(Icons.shield, color: AppColors.primary, size: 24),
                            const SizedBox(width: AppSpacing.s),
                            Text(
                              '100% On-Device Privacy Guaranteed',
                              style: AppTypography.headlineMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '• OTPs, personal SMS, and private chats are NEVER read or stored.\n• All UPI text parsing runs locally on your smartphone.\n• Zero data leaves your device without your explicit consent.',
                          style: AppTypography.labelSmall.copyWith(fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 4: K2i AI Intelligence Advisory Card
                  MMAIInsightCard(
                    title: 'Real-Time Transaction Categorization',
                    description:
                        'Once enabled, K2i AI recognizes merchants like Starbucks, Swiggy, Uber, and Amazon automatically upon payment receipt.',
                    actionLabel: 'View Payment Methods (Screen #31)',
                    onAction: () => context.go(AppRoutes.paymentMethods),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: Action Buttons
                  MMButton(
                    label: 'Enable UPI Auto-Tracking',
                    onPressed: () {
                      setState(() => _isUpiTrackingEnabled = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('UPI Automatic Tracking enabled successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.go(AppRoutes.paymentMethods);
                    },
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Skip for Now',
                    onPressed: () => context.go(AppRoutes.transactions),
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

  Widget _buildAppToggleRow(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Payment Methods Screen (07cc6e59a89c43038737825c1643efaf)
class PaymentMethodsPage extends ConsumerStatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  ConsumerState<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends ConsumerState<PaymentMethodsPage> {
  @override
  Widget build(BuildContext context) {
    final userWallets = ref.watch(userWalletsProvider);
    final primaryWallet = userWallets.cast<WalletItem?>().firstWhere(
      (w) => w?.isPrimary == true,
      orElse: () => userWallets.isNotEmpty ? userWallets.first : null,
    );

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
              context.go(AppRoutes.transactions);
            }
          },
        ),
        title: Text(
          'Payment Methods & Wallets',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card, color: AppColors.primary),
            tooltip: 'Add Wallet',
            onPressed: () => context.go(AppRoutes.addWalletSelection),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LINKED FINANCIAL ACCOUNTS',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            MMStatusChip(
                              label: '${userWallets.length} Accounts Active',
                              backgroundColor: const Color(0xFFE8F5E9),
                              textColor: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'Primary Payment Method',
                          style: AppTypography.labelSmall,
                        ),
                        Text(
                          primaryWallet?.name ?? 'No Primary Wallet Selected',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  if (userWallets.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.outlineVariant, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.credit_card_off_outlined, size: 48, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'No Payment Methods Linked',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap "+ Add Wallet" below to add a bank account, credit card, or UPI wallet.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          MMButton(
                            label: '+ Add Wallet / Bank Account',
                            onPressed: () => context.go(AppRoutes.addWalletSelection),
                            type: MMButtonType.primary,
                            fullWidth: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ] else ...[
                    MMSectionHeader(
                      title: 'Your Payment Methods',
                      subtitle: 'Select primary method for transactions',
                      actionLabel: '+ Add Wallet',
                      onAction: () => context.go(AppRoutes.addWalletSelection),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    ...userWallets.map((wallet) {
                      IconData icon = Icons.account_balance;
                      Color iconColor = AppColors.primary;

                      if (wallet.type == 'Credit Card') {
                        icon = Icons.credit_card;
                        iconColor = AppColors.secondary;
                      } else if (wallet.type == 'UPI' || wallet.type == 'Digital Wallet') {
                        icon = Icons.account_balance_wallet;
                        iconColor = AppColors.aiAccent;
                      } else if (wallet.type == 'Cash') {
                        icon = Icons.payments_outlined;
                        iconColor = AppColors.primary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
                        child: MMPaymentMethodTile(
                          title: wallet.name,
                          subtitle: '${wallet.type} • Available Bal: ₹${wallet.balance.toStringAsFixed(2)}',
                          icon: icon,
                          iconColor: iconColor,
                          isPrimary: wallet.isPrimary,
                          onTap: () {
                            ref.read(userWalletsProvider.notifier).setPrimary(wallet.id);
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  MMButton(
                    label: 'Add New Wallet / Bank Account',
                    onPressed: () => context.go(AppRoutes.addWalletSelection),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'View All Wallets Overview',
                    onPressed: () => context.go(AppRoutes.wallets),
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

/// Stitch Screen: MoneyMateX Wallets Overview (View A) (bfdffc8425ed4c67b1fb170832e9d348)
class WalletsPage extends ConsumerStatefulWidget {
  const WalletsPage({super.key});

  @override
  ConsumerState<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends ConsumerState<WalletsPage> {
  String _selectedFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Bank Accounts',
    'Credit Cards',
    'Digital Wallets',
  ];

  @override
  Widget build(BuildContext context) {
    final userWallets = ref.watch(userWalletsProvider);
    final double totalBalance = userWallets.fold(0.0, (sum, w) => sum + w.balance);

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
              context.go(AppRoutes.settings);
            }
          },
        ),
        title: Text(
          'Wallets Overview',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Wallet',
            onPressed: () => context.go(AppRoutes.addWalletSelection),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL NET LIQUIDITY',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            MMStatusChip(
                              label: '${userWallets.length} Wallets Linked',
                              backgroundColor: const Color(0xFFE8F5E9),
                              textColor: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '₹${totalBalance.toStringAsFixed(2)}',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  if (userWallets.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.outlineVariant, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'No Wallets Added Yet',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap "+ Add Wallet" below to connect your bank account, credit card, cash, or UPI wallet.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          MMButton(
                            label: '+ Add Wallet / Connect Bank',
                            onPressed: () => context.go(AppRoutes.addWalletSelection),
                            type: MMButtonType.primary,
                            fullWidth: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ] else ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((f) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: MMCategoryChip(
                              label: f,
                              isSelected: _selectedFilter == f,
                              onSelected: () => setState(() => _selectedFilter = f),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.stackLg),

                    ...userWallets.map((wallet) {
                      IconData icon = Icons.account_balance;
                      Color cardColor = AppColors.primary;

                      if (wallet.type == 'Credit Card') {
                        icon = Icons.credit_card;
                        cardColor = AppColors.secondary;
                      } else if (wallet.type == 'UPI' || wallet.type == 'Digital Wallet') {
                        icon = Icons.account_balance_wallet;
                        cardColor = AppColors.aiAccent;
                      } else if (wallet.type == 'Cash') {
                        icon = Icons.payments_outlined;
                        cardColor = AppColors.primary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
                        child: MMWalletCard(
                          accountName: wallet.name,
                          accountType: wallet.type,
                          accountNumber: wallet.provider,
                          balance: '₹${wallet.balance.toStringAsFixed(2)}',
                          changePercentage: wallet.trackingMethod,
                          icon: icon,
                          cardColor: cardColor,
                          isPrimary: wallet.isPrimary,
                          onTap: () {},
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  MMButton(
                    label: '+ Add Wallet or Connect Bank Account',
                    onPressed: () => context.go(AppRoutes.addWalletSelection),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Configure Tracking Preferences',
                    onPressed: () => context.go(AppRoutes.trackingSetup),
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

/// Stitch Screen: MoneyMateX Wallets Overview (View B) (49e278025d534b97b7ea4f28513d51c7)
class WalletsDetailedPage extends StatefulWidget {
  const WalletsDetailedPage({super.key});

  @override
  State<WalletsDetailedPage> createState() => _WalletsDetailedPageState();
}

class _WalletsDetailedPageState extends State<WalletsDetailedPage> {
  String _selectedFilter = 'All Accounts';

  final List<String> _filters = const [
    'All Accounts',
    'High Interest',
    'Credit Lines',
    'Auto-Tracked',
  ];

  @override
  Widget build(BuildContext context) {
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
          'Detailed Wallets Breakdown',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_agenda_outlined, color: AppColors.primary),
            tooltip: 'View Compact Overview A',
            onPressed: () => context.go(AppRoutes.wallets),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Wallet',
            onPressed: () => context.go(AppRoutes.addWalletSelection),
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
                  // Section 1: Detailed Liquidity Allocation Card
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL LIQUID ASSET ALLOCATION',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const MMStatusChip(
                              label: '4 Accounts',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '₹5,80,000',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 38,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const MMProgressBar(progress: 0.741, height: 8),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Savings: ₹4,30,000 (74.1%)', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                            Text('Credit & UPI: ₹1,50,000 (25.9%)', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Filter Chips Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: f,
                            isSelected: _selectedFilter == f,
                            onSelected: () => setState(() => _selectedFilter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Detailed Account Cards
                  // Account 1: HDFC Savings
                  if (_selectedFilter == 'All Accounts' || _selectedFilter == 'High Interest') ...[
                    _buildDetailedAccountCard(
                      accountName: 'HDFC Priority Savings Account',
                      accountType: 'Savings Account • 3.5% APY',
                      balanceText: '₹2,45,000',
                      subtext: 'Acc •••• 9842 • Earned ₹715 interest this month',
                      icon: Icons.account_balance,
                      iconColor: AppColors.primary,
                      isPrimary: true,
                      progress: 0.57,
                      actionLabel: 'View Transactions',
                      onAction: () => context.go(AppRoutes.transactions),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    _buildDetailedAccountCard(
                      accountName: 'ICICI Savings Reserve Account',
                      accountType: 'Savings Account • 3.5% APY',
                      balanceText: '₹1,85,000',
                      subtext: 'Acc •••• 4120 • Earned ₹540 interest this month',
                      icon: Icons.account_balance,
                      iconColor: AppColors.tertiary,
                      isPrimary: false,
                      progress: 0.43,
                      actionLabel: 'View Transactions',
                      onAction: () => context.go(AppRoutes.transactions),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                  ],

                  if (_selectedFilter == 'All Accounts' || _selectedFilter == 'Credit Lines') ...[
                    _buildDetailedAccountCard(
                      accountName: 'HDFC Regalia Credit Card',
                      accountType: 'Credit Card • 82% Utilized',
                      balanceText: '₹1,23,000 / ₹1,50,000',
                      subtext: 'Card •••• 5512 • Due 18th Aug 2026',
                      icon: Icons.credit_card,
                      iconColor: AppColors.secondary,
                      isPrimary: false,
                      progress: 0.82,
                      actionLabel: 'Pay Credit Card Bill',
                      onAction: () => context.go(AppRoutes.bills),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                  ],

                  if (_selectedFilter == 'All Accounts' || _selectedFilter == 'Auto-Tracked') ...[
                    _buildDetailedAccountCard(
                      accountName: 'Paytm Digital Wallet & UPI',
                      accountType: 'Digital Wallet • Auto-Tracked',
                      balanceText: '₹15,000',
                      subtext: 'UPI ID: kathir@paytm • Active SMS Listener',
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.aiAccent,
                      isPrimary: false,
                      progress: 0.10,
                      actionLabel: 'Configure UPI Tracking',
                      onAction: () => context.go(AppRoutes.upiSetup),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Section 4: K2i AI Advisory Card
                  MMAIInsightCard(
                    title: 'Emergency Cushion & Yield Optimization',
                    description: 'Your 6-month liquid cushion target is ₹3,00,000. You have ₹4,30,000 liquid reserves. Moving ₹1,30,000 surplus to short-term liquid funds will yield an extra +₹5,850/year.',
                    actionLabel: 'Connect Bank for Auto-Sweep',
                    onAction: () => context.go(AppRoutes.connectBank),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: Action Buttons
                  MMButton(
                    label: '+ Connect New Bank Account',
                    onPressed: () => context.go(AppRoutes.connectBank),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Return to Compact Overview (View A)',
                    onPressed: () => context.go(AppRoutes.wallets),
                    type: MMButtonType.secondary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Manage Payment Methods & UPI',
                    onPressed: () => context.go(AppRoutes.paymentMethods),
                    type: MMButtonType.text,
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

  Widget _buildDetailedAccountCard({
    required String accountName,
    required String accountType,
    required String balanceText,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required bool isPrimary,
    required double progress,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isPrimary ? AppColors.primary : AppColors.outlineVariant,
          width: isPrimary ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(accountName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(accountType, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              if (isPrimary)
                const MMStatusChip(
                  label: 'PRIMARY',
                  backgroundColor: AppColors.primaryContainer,
                  textColor: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subtext, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
              Text(balanceText, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          MMProgressBar(progress: progress, height: 4),
          const SizedBox(height: AppSpacing.m),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
              label: Text(actionLabel, style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Add Wallet: Selection (eb77d61880b1468ead4d89cb0ec159be)
class AddWalletSelectionPage extends ConsumerStatefulWidget {
  const AddWalletSelectionPage({super.key});

  @override
  ConsumerState<AddWalletSelectionPage> createState() => _AddWalletSelectionPageState();
}

class _AddWalletSelectionPageState extends ConsumerState<AddWalletSelectionPage> {
  String _selectedCategory = 'bank'; // 'bank', 'debit', 'credit', 'upi', 'cash', 'digital', 'other'
  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _initialBalanceController = TextEditingController();

  @override
  void dispose() {
    _walletNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final customName = _walletNameController.text.trim();
    final balanceText = _initialBalanceController.text.trim();
    final balance = double.tryParse(balanceText.replaceAll(',', '')) ?? 0.0;

    if (_selectedCategory == 'bank' || _selectedCategory == 'debit' || _selectedCategory == 'credit') {
      context.go(AppRoutes.connectBank);
      return;
    }

    // Handle UPI / Cash / Digital Wallet / Other direct creation
    String walletType = 'Other';
    String providerName = customName.isNotEmpty ? customName : 'My Wallet';

    if (_selectedCategory == 'upi') {
      walletType = 'UPI';
      if (customName.isEmpty) providerName = 'UPI Wallet / GPay';
    } else if (_selectedCategory == 'cash') {
      walletType = 'Cash';
      if (customName.isEmpty) providerName = 'Cash Vault';
    } else if (_selectedCategory == 'digital') {
      walletType = 'Digital Wallet';
      if (customName.isEmpty) providerName = 'Paytm Wallet';
    }

    final newWallet = WalletItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: providerName,
      type: walletType,
      provider: providerName,
      balance: balance,
      createdAt: DateTime.now(),
      trackingMethod: 'Manual',
      isPrimary: false,
    );

    ref.read(userWalletsProvider.notifier).addWallet(newWallet);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$providerName added successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go(AppRoutes.trackingSetup);
  }

  @override
  Widget build(BuildContext context) {
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
          'Add Wallet / Account',
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
                    'Choose how you want to track your money',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select an account category below to link your savings bank, credit card, cash vault, or UPI wallet to MoneyMateX.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  _buildOptionTile(
                    id: 'bank',
                    title: 'Bank Account',
                    subtitle: 'Link via RBI Account Aggregator framework (HDFC, ICICI, SBI, Axis)',
                    badgeLabel: 'Instant Auto-Sync',
                    badgeColor: const Color(0xFFE8F5E9),
                    badgeTextColor: const Color(0xFF2E7D32),
                    icon: Icons.account_balance,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildOptionTile(
                    id: 'debit',
                    title: 'Debit Card',
                    subtitle: 'Track debit card spend linked to your primary bank account',
                    badgeLabel: 'Card Sync',
                    badgeColor: AppColors.primaryContainer,
                    badgeTextColor: AppColors.primary,
                    icon: Icons.credit_card,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildOptionTile(
                    id: 'credit',
                    title: 'Credit Card',
                    subtitle: 'Track statements, credit limits, due dates & bill reminders',
                    badgeLabel: 'Statement Parsing',
                    badgeColor: AppColors.secondaryContainer,
                    badgeTextColor: AppColors.onSecondaryContainer,
                    icon: Icons.credit_card,
                    iconColor: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildOptionTile(
                    id: 'upi',
                    title: 'UPI',
                    subtitle: 'Google Pay, PhonePe, Paytm & UPI payment apps',
                    badgeLabel: 'SMS Auto-Tracking',
                    badgeColor: AppColors.tertiaryContainer,
                    badgeTextColor: AppColors.onTertiaryContainer,
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.aiAccent,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildOptionTile(
                    id: 'cash',
                    title: 'Cash',
                    subtitle: 'Physical cash in wallet, safe, or envelope budgeting',
                    badgeLabel: 'Manual Entry',
                    badgeColor: AppColors.surfaceContainerHigh,
                    badgeTextColor: AppColors.onSurfaceVariant,
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildOptionTile(
                    id: 'digital',
                    title: 'Digital Wallet',
                    subtitle: 'Paytm Wallet, Amazon Pay Balance & Prepaid Wallets',
                    badgeLabel: 'Wallet Sync',
                    badgeColor: AppColors.secondaryContainer,
                    badgeTextColor: AppColors.secondary,
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),

                  _buildOptionTile(
                    id: 'other',
                    title: 'Other',
                    subtitle: 'Custom financial asset or custom store credit account',
                    badgeLabel: 'Custom',
                    badgeColor: AppColors.surfaceContainerHigh,
                    badgeTextColor: AppColors.onSurfaceVariant,
                    icon: Icons.account_balance,
                    iconColor: AppColors.primary,
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  if (_selectedCategory == 'upi' || _selectedCategory == 'cash' || _selectedCategory == 'digital' || _selectedCategory == 'other') ...[
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
                          Text('Wallet Details', style: AppTypography.labelSmall),
                          const SizedBox(height: AppSpacing.m),
                          MMTextField(
                            label: 'Wallet Name / Label',
                            hint: 'e.g. Cash in Wallet, GPay, Paytm',
                            controller: _walletNameController,
                            prefixIcon: const Icon(Icons.label_outlined),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          MMTextField(
                            label: 'Initial Balance (Optional ₹)',
                            hint: '0.00',
                            controller: _initialBalanceController,
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.currency_rupee),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  MMButton(
                    label: 'Continue to Setup',
                    onPressed: _onContinue,
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Cancel & Return to Wallets',
                    onPressed: () => context.go(AppRoutes.wallets),
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

  Widget _buildOptionTile({
    required String id,
    required String title,
    required String subtitle,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeTextColor,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedCategory == id;

    return InkWell(
      onTap: () => setState(() => _selectedCategory = id),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      MMStatusChip(
                        label: badgeLabel,
                        backgroundColor: badgeColor,
                        textColor: badgeTextColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Add Wallet: Connect Bank (f1ab89767f66421bb33626ad09b078dd)
class ConnectBankPage extends ConsumerStatefulWidget {
  const ConnectBankPage({super.key});

  @override
  ConsumerState<ConnectBankPage> createState() => _ConnectBankPageState();
}

class _ConnectBankPageState extends ConsumerState<ConnectBankPage> {
  String _selectedBank = 'HDFC Bank';
  String _trackingMethod = 'Automatic Tracking'; // 'Automatic Tracking' vs 'Manual Tracking'
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  bool _agreedConsent = true;

  final List<String> _popularBanks = const [
    'HDFC Bank',
    'ICICI Bank',
    'State Bank of India',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Custom Bank Account',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _onAuthorizeAndSave() {
    if (!_agreedConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the consent terms to proceed.')),
      );
      return;
    }

    final customNickname = _nicknameController.text.trim();
    final accountName = customNickname.isNotEmpty ? customNickname : '$_selectedBank Account';
    final balanceText = _balanceController.text.trim();
    final balance = double.tryParse(balanceText.replaceAll(',', '')) ?? 0.0;

    final newWallet = WalletItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: accountName,
      type: 'Bank Account',
      provider: _selectedBank,
      balance: balance,
      createdAt: DateTime.now(),
      trackingMethod: _trackingMethod,
      isPrimary: ref.read(userWalletsProvider).isEmpty,
    );

    ref.read(userWalletsProvider.notifier).addWallet(newWallet);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Frontend bank connection preference saved for $accountName!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go(AppRoutes.trackingSetup);
  }

  @override
  Widget build(BuildContext context) {
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
              context.go(AppRoutes.addWalletSelection);
            }
          },
        ),
        title: Text(
          'Connect Bank Account',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'BANK CONNECTION PREFERENCE',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const MMStatusChip(
                              label: 'Frontend Safe Flow',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'Link Bank Account Preference',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select your bank account and tracking method to organize your money in MoneyMateX.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  const MMSectionHeader(
                    title: 'Select Bank Institution',
                    subtitle: 'Choose your primary bank',
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMDropdownField<String>(
                    label: 'Bank Institution',
                    value: _selectedBank,
                    items: _popularBanks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBank = val);
                    },
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  const MMSectionHeader(
                    title: 'Select Tracking Method',
                    subtitle: 'Choose how transactions will be recorded',
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Automatic Tracking'),
                          selected: _trackingMethod == 'Automatic Tracking',
                          onSelected: (_) => setState(() => _trackingMethod = 'Automatic Tracking'),
                          selectedColor: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Manual Tracking'),
                          selected: _trackingMethod == 'Manual Tracking',
                          onSelected: (_) => setState(() => _trackingMethod = 'Manual Tracking'),
                          selectedColor: AppColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

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
                        Text('Account Information', style: AppTypography.labelSmall),
                        const SizedBox(height: AppSpacing.m),
                        MMTextField(
                          label: 'Account Nickname (Optional)',
                          hint: 'e.g. Primary Salary Account',
                          controller: _nicknameController,
                          prefixIcon: const Icon(Icons.label_outlined),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMTextField(
                          label: 'Account Balance (Optional ₹)',
                          hint: 'e.g. 25000',
                          controller: _balanceController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreedConsent,
                              onChanged: (val) => setState(() => _agreedConsent = val ?? false),
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Save this bank connection preference locally in MoneyMateX.',
                                  style: AppTypography.labelSmall.copyWith(fontSize: 12, height: 1.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: 'Save & Connect Bank Account',
                    onPressed: _onAuthorizeAndSave,
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Cancel & Return to Selection',
                    onPressed: () => context.go(AppRoutes.addWalletSelection),
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

/// Stitch Screen: MoneyMateX Tracking Setup Screen
class TrackingSetupPage extends ConsumerStatefulWidget {
  const TrackingSetupPage({super.key});

  @override
  ConsumerState<TrackingSetupPage> createState() => _TrackingSetupPageState();
}

class _TrackingSetupPageState extends ConsumerState<TrackingSetupPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(trackingSettingsProvider);
    final notifier = ref.read(trackingSettingsProvider.notifier);

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
          'Tracking Setup',
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
                    'Configure Smart Tracking Preferences',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tailor how MoneyMateX detects, categorizes, and alerts you about your spending and financial goals.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

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
                        _buildSettingToggle(
                          title: 'Automatic Transaction Detection',
                          subtitle: 'Enable zero-effort automatic tracking preference',
                          value: settings.automaticTracking,
                          onChanged: (val) => notifier.setAutomaticTracking(val),
                          icon: Icons.sensors_outlined,
                        ),
                        const Divider(height: 24, color: AppColors.outlineVariant),
                        _buildSettingToggle(
                          title: 'Automatic Categorization',
                          subtitle: 'Smartly tag Swiggy, Uber, Amazon & merchants using AI rules',
                          value: settings.automaticCategorization,
                          onChanged: (val) => notifier.setAutomaticCategorization(val),
                          icon: Icons.auto_awesome_outlined,
                        ),
                        const Divider(height: 24, color: AppColors.outlineVariant),
                        _buildSettingToggle(
                          title: 'Budget Alerts',
                          subtitle: 'Get notified when spending reaches 80% of category ceiling',
                          value: settings.budgetAlerts,
                          onChanged: (val) => notifier.setBudgetAlerts(val),
                          icon: Icons.notifications_active_outlined,
                        ),
                        const Divider(height: 24, color: AppColors.outlineVariant),
                        _buildSettingToggle(
                          title: 'Smart Spending Alerts',
                          subtitle: 'Receive insights on unusual transaction spikes',
                          value: settings.smartSpendingAlerts,
                          onChanged: (val) => notifier.setSmartSpendingAlerts(val),
                          icon: Icons.insights_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: 'Save Tracking Preferences',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tracking preferences saved successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.go(AppRoutes.wallets);
                    },
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Skip & Go to Transactions',
                    onPressed: () => context.go(AppRoutes.transactions),
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

  Widget _buildSettingToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }
}

