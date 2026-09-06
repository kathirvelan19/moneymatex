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
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../providers/bills_provider.dart';

/// Stitch Screen 1: MoneyMateX Bills & Reminders Overview (54ac90426fb44659a5bdbbbb568bc37e)
class BillsOverviewPage extends ConsumerStatefulWidget {
  const BillsOverviewPage({super.key});

  @override
  ConsumerState<BillsOverviewPage> createState() => _BillsOverviewPageState();
}

class _BillsOverviewPageState extends ConsumerState<BillsOverviewPage> {
  String _selectedTab = 'All';

  final List<String> _tabs = const ['All', 'Upcoming', 'Paid', 'Recurring'];

  @override
  Widget build(BuildContext context) {
    final bills = ref.watch(billsProvider);
    final upcomingBills = bills.where((b) => b.status != 'Paid').toList();
    final double totalUpcoming = upcomingBills.fold(0.0, (sum, b) => sum + b.amount);

    final filteredBills = bills.where((b) {
      if (_selectedTab == 'Upcoming') return b.status == 'Upcoming' || b.status == 'Overdue';
      if (_selectedTab == 'Paid') return b.status == 'Paid';
      if (_selectedTab == 'Recurring') return b.isRecurring;
      return true;
    }).toList();

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
          'Bills & Reminders',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Bill',
            onPressed: () => context.go(AppRoutes.addBill),
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
                  // Hero Header Summary Card
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
                              'TOTAL UPCOMING COMMITTED',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            MMStatusChip(
                              label: '${upcomingBills.length} Due Soon',
                              backgroundColor: upcomingBills.isNotEmpty
                                  ? AppColors.secondaryContainer
                                  : const Color(0xFFE8F5E9),
                              textColor: upcomingBills.isNotEmpty
                                  ? AppColors.secondary
                                  : const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '₹${totalUpcoming.toStringAsFixed(2)}',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Total value of user bills due for current billing cycle.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  if (bills.isEmpty) ...[
                    // Empty State Card
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
                          const Icon(Icons.receipt_long_outlined, size: 52, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'No Upcoming Bills or Reminders',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap "+ Add Bill" below to add your electricity, rent, internet, or subscription reminders.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          MMButton(
                            label: '+ Add Bill Reminder',
                            onPressed: () => context.go(AppRoutes.addBill),
                            type: MMButtonType.primary,
                            fullWidth: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ] else ...[
                    // Filter Chips Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tabs.map((tab) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: MMCategoryChip(
                              label: tab,
                              isSelected: _selectedTab == tab,
                              onSelected: () => setState(() => _selectedTab = tab),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.stackLg),

                    // User Bills List
                    ...filteredBills.map((bill) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
                        child: _buildBillCard(context, bill),
                      );
                    }),

                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  MMButton(
                    label: '+ Add New Bill / Reminder',
                    onPressed: () => context.go(AppRoutes.addBill),
                    type: MMButtonType.primary,
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

  Widget _buildBillCard(BuildContext context, BillItem bill) {
    Color statusColor = const Color(0xFF2E7D32);
    Color statusBg = const Color(0xFFE8F5E9);

    if (bill.status == 'Upcoming') {
      statusColor = AppColors.primary;
      statusBg = AppColors.primaryContainer;
    } else if (bill.status == 'Overdue') {
      statusColor = AppColors.error;
      statusBg = AppColors.errorContainer;
    }

    return InkWell(
      onTap: () => context.go('/bills/${bill.id}'),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bill.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${bill.category} • ${bill.frequency}', style: AppTypography.labelSmall.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                MMStatusChip(
                  label: bill.status,
                  backgroundColor: statusBg,
                  textColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Due: ${bill.dueDate}', style: AppTypography.labelSmall.copyWith(fontSize: 12)),
                Text('₹${bill.amount.toStringAsFixed(2)}', style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stitch Screen 1B: Dashboard Stub Map
class BillsDashboardPage extends StatelessWidget {
  const BillsDashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const BillsOverviewPage();
}

/// Stitch Screen 2: Add Bill (78b51de5ce3b4df98a13bbae0f3906d5)
class AddBillPage extends ConsumerStatefulWidget {
  const AddBillPage({super.key});

  @override
  ConsumerState<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends ConsumerState<AddBillPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController(text: '15th of month');
  String _selectedCategory = 'Bills & Utilities';
  String _selectedFrequency = 'Monthly';
  String _selectedPaymentMethod = 'UPI / GPay';
  bool _isRecurring = true;
  bool _reminderEnabled = true;

  final List<String> _categories = const [
    'Bills & Utilities',
    'Housing & Rent',
    'Subscriptions',
    'Entertainment',
    'Health & Wellness',
    'Other Expense',
  ];

  final List<String> _frequencies = const [
    'Monthly',
    'Quarterly',
    'Yearly',
    'One-Time',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _onSaveBill() {
    final name = _nameController.text.trim();
    final rawAmount = _amountController.text.trim();
    final amount = double.tryParse(rawAmount.replaceAll(',', ''));

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a bill name.')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bill amount.')),
      );
      return;
    }

    final newBill = BillItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: _selectedCategory,
      amount: amount,
      dueDate: _dueDateController.text.trim(),
      frequency: _selectedFrequency,
      paymentMethod: _selectedPaymentMethod,
      isRecurring: _isRecurring,
      reminderEnabled: _reminderEnabled,
      status: 'Upcoming',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(billsProvider.notifier).addBill(newBill);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bill "$name" added successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go(AppRoutes.bills);
  }

  @override
  Widget build(BuildContext context) {
    final userWallets = ref.watch(userWalletsProvider);
    final availableWallets = [
      'UPI / GPay',
      'Cash Vault',
      'HDFC Credit Card',
      ...userWallets.map((w) => w.name),
    ];

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
              context.go(AppRoutes.bills);
            }
          },
        ),
        title: Text(
          'Add Bill / Reminder',
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
                    'Create New Bill Commitment',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter bill details to set up automatic reminders and payment tracking.',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MMTextField(
                          label: 'Bill Name / Biller',
                          hint: 'e.g. Internet Bill, Rent, Electricity',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.receipt_long_outlined),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMTextField(
                          label: 'Bill Amount (₹)',
                          hint: 'e.g. 1500',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMDropdownField<String>(
                          label: 'Category',
                          value: _selectedCategory,
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMTextField(
                          label: 'Due Date / Payment Day',
                          hint: 'e.g. 15th of month, 2026-08-20',
                          controller: _dueDateController,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMDropdownField<String>(
                          label: 'Frequency',
                          value: _selectedFrequency,
                          items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedFrequency = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMDropdownField<String>(
                          label: 'Payment Method / Wallet',
                          value: availableWallets.contains(_selectedPaymentMethod) ? _selectedPaymentMethod : availableWallets.first,
                          items: availableWallets.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPaymentMethod = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Recurring Bill Commitment', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                Text('Automatically renews every billing cycle', style: AppTypography.labelSmall.copyWith(fontSize: 12)),
                              ],
                            ),
                            Switch(
                              value: _isRecurring,
                              onChanged: (val) => setState(() => _isRecurring = val),
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Enable Reminder Push', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                Text('Get notified 3 days before due date', style: AppTypography.labelSmall.copyWith(fontSize: 12)),
                              ],
                            ),
                            Switch(
                              value: _reminderEnabled,
                              onChanged: (val) => setState(() => _reminderEnabled = val),
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: 'Save Bill Reminder',
                    onPressed: _onSaveBill,
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Cancel',
                    onPressed: () => context.go(AppRoutes.bills),
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

/// Stitch Screen 3: Bill Details (7577ae7baef34cdfa6075c0976f25c6d)
class BillDetailsPage extends ConsumerWidget {
  final String id;
  const BillDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);
    final bill = bills.cast<BillItem?>().firstWhere((b) => b?.id == id, orElse: () => null);

    if (bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bill Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bill not found'),
              const SizedBox(height: 16),
              MMButton(label: 'Back to Bills', onPressed: () => context.go(AppRoutes.bills)),
            ],
          ),
        ),
      );
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
              context.go(AppRoutes.bills);
            }
          },
        ),
        title: Text(
          bill.name,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Bill',
            onPressed: () {
              ref.read(billsProvider.notifier).deleteBill(bill.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bill "${bill.name}" deleted.')),
              );
              context.go(AppRoutes.bills);
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
                            Text('BILL COMMITMENT DETAILS', style: AppTypography.labelSmall),
                            MMStatusChip(
                              label: bill.status,
                              backgroundColor: bill.status == 'Paid'
                                  ? const Color(0xFFE8F5E9)
                                  : AppColors.primaryContainer,
                              textColor: bill.status == 'Paid'
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '₹${bill.amount.toStringAsFixed(2)}',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const Divider(height: 1, color: AppColors.outlineVariant),
                        const SizedBox(height: AppSpacing.m),
                        _buildDetailRow('Category', bill.category),
                        _buildDetailRow('Due Date', bill.dueDate),
                        _buildDetailRow('Frequency', bill.frequency),
                        _buildDetailRow('Payment Method', bill.paymentMethod),
                        _buildDetailRow('Recurring Status', bill.isRecurring ? 'Recurring' : 'One-Time'),
                        _buildDetailRow('Reminders', bill.reminderEnabled ? 'Enabled' : 'Disabled'),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  if (bill.status != 'Paid') ...[
                    MMButton(
                      label: 'Pay Bill Now (₹${bill.amount.toStringAsFixed(2)})',
                      onPressed: () => context.go(AppRoutes.billConfirmation, extra: bill.toMap()),
                      type: MMButtonType.primary,
                      fullWidth: true,
                    ),
                    const SizedBox(height: AppSpacing.s),
                  ],

                  MMButton(
                    label: 'View Payment History (${bill.paymentHistory.length})',
                    onPressed: () => context.go('/bills/${bill.id}/full'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.labelSmall),
          Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

extension BillItemMap on BillItem {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'dueDate': dueDate,
      'frequency': frequency,
      'paymentMethod': paymentMethod,
    };
  }
}

/// Stitch Screen 4: Bill Details / Payment History (6c2d74ce1a444bd4a334fd430415f0ed)
class BillDetailsFullPage extends ConsumerWidget {
  final String id;
  const BillDetailsFullPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);
    final bill = bills.cast<BillItem?>().firstWhere((b) => b?.id == id, orElse: () => null);

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
              context.go('/bills/$id');
            }
          },
        ),
        title: Text(
          '${bill?.name ?? "Bill"} Payment History',
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
                  if (bill == null || bill.paymentHistory.isEmpty) ...[
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
                          const Icon(Icons.history_toggle_off_outlined, size: 48, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'No Payment History Recorded',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No payments have been completed for this bill yet.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...bill.paymentHistory.map((record) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.stackSm),
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.outlineVariant, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 28),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment Completed', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                  Text('${record.paymentMethod} • ${record.paymentDate.toString().split(" ")[0]}', style: AppTypography.labelSmall.copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              '₹${record.amount.toStringAsFixed(2)}',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: AppSpacing.stackLg),
                  MMButton(
                    label: 'Back to Bill Details',
                    onPressed: () => context.go('/bills/$id'),
                    type: MMButtonType.secondary,
                    fullWidth: true,
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

/// Stitch Screen 5: Subscription / Recurring Details (ea8e156aeee947a5bd035a99547fe750)
class SubscriptionDetailsPage extends StatelessWidget {
  final String id;
  const SubscriptionDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) => BillDetailsPage(id: id);
}

/// Stitch Screen 6: Create Payment / Bill Confirmation (a5f01ddba9c14184b27ca22b2098feb4)
class BillConfirmationPage extends ConsumerStatefulWidget {
  const BillConfirmationPage({super.key});

  @override
  ConsumerState<BillConfirmationPage> createState() => _BillConfirmationPageState();
}

class _BillConfirmationPageState extends ConsumerState<BillConfirmationPage> {
  String _selectedPaymentMethod = 'UPI / GPay';

  void _onConfirmPayment(Map<String, dynamic>? extra) {
    final billId = extra?['id']?.toString() ?? '';
    final name = extra?['name']?.toString() ?? 'Bill Payment';
    final category = extra?['category']?.toString() ?? 'Bills & Utilities';
    final amount = double.tryParse(extra?['amount']?.toString() ?? '0') ?? 0.0;

    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Record payment history in BillItem
    final record = BillPaymentRecord(
      id: transactionId,
      billId: billId,
      amount: amount,
      paymentDate: DateTime.now(),
      paymentMethod: _selectedPaymentMethod,
      transactionId: transactionId,
    );

    ref.read(billsProvider.notifier).recordPayment(billId, record);

    // 2. Create expense transaction in transactionsProvider
    final newTransaction = TransactionItem(
      id: transactionId,
      title: 'Bill Payment: $name',
      category: category,
      amount: amount,
      date: DateTime.now(),
      paymentMethod: _selectedPaymentMethod,
      wallet: _selectedPaymentMethod,
      isExpense: true,
      icon: Icons.receipt_long,
      notes: 'Paid via MoneyMateX Bill Pay',
    );

    ref.read(transactionsProvider.notifier).addTransaction(newTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paid ₹${amount.toStringAsFixed(2)} for $name successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go(AppRoutes.transactions);
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final name = extra?['name']?.toString() ?? 'Bill Payment';
    final amount = double.tryParse(extra?['amount']?.toString() ?? '0') ?? 0.0;

    final userWallets = ref.watch(userWalletsProvider);
    final availableWallets = [
      'UPI / GPay',
      'Cash Vault',
      'HDFC Credit Card',
      ...userWallets.map((w) => w.name),
    ];

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
              context.go(AppRoutes.bills);
            }
          },
        ),
        title: Text(
          'Confirm Bill Payment',
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
                        Text('BILL PAYMENT SUMMARY', style: AppTypography.labelSmall),
                        const SizedBox(height: AppSpacing.s),
                        Text(name, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMDropdownField<String>(
                          label: 'Select Payment Method / Wallet',
                          value: availableWallets.contains(_selectedPaymentMethod) ? _selectedPaymentMethod : availableWallets.first,
                          items: availableWallets.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPaymentMethod = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: 'Confirm & Complete Payment (₹${amount.toStringAsFixed(2)})',
                    onPressed: () => _onConfirmPayment(extra),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Cancel',
                    onPressed: () => context.go(AppRoutes.bills),
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
