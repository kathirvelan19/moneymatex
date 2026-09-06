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
import '../../../accounts/presentation/providers/user_wallets_provider.dart';
import '../providers/bills_provider.dart';

/// Stitch Screen 7 — Add Bill / Bill Details Form Page
class AddBillPage extends ConsumerStatefulWidget {
  const AddBillPage({super.key});

  @override
  ConsumerState<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends ConsumerState<AddBillPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  String _category = 'Bills & Utilities';
  String _frequency = 'Monthly';
  String _paymentMethod = 'UPI';
  bool _reminder1Day = true;
  bool _reminder2Days = false;
  bool _reminderOnDue = true;
  String? _nameError;
  String? _amountError;

  final List<String> _categories = const [
    'Bills & Utilities',
    'Housing & Rent',
    'Subscriptions',
    'Education',
    'Insurance',
    'Other',
  ];

  final List<String> _frequencies = const ['Monthly', 'Quarterly', 'Annually'];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _saveBill() async {
    final name = _nameController.text.trim();
    final amtStr = _amountController.text.trim();

    bool valid = true;
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter bill name');
      valid = false;
    }
    if (amtStr.isEmpty || double.tryParse(amtStr) == null) {
      setState(() => _amountError = 'Please enter a valid amount');
      valid = false;
    }
    if (!valid) return;

    final amount = double.parse(amtStr);
    final dueDate = _dueDateController.text.trim().isEmpty ? '24th of month' : _dueDateController.text.trim();

    final newBill = BillItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: _category,
      amount: amount,
      dueDate: dueDate,
      frequency: _frequency,
      paymentMethod: _paymentMethod,
      isRecurring: true,
      reminderEnabled: _reminder1Day || _reminderOnDue,
      reminderTime: '09:00 AM',
      status: 'Upcoming',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(billsProvider.notifier).addBill(newBill);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill "${newBill.name}" added successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.bills);
      }
    }
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
              context.go(AppRoutes.bills);
            }
          },
        ),
        title: Text(
          'Add Bill',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up recurring payments & automatic due notifications.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            MMTextField(
              label: 'Bill Name',
              hint: 'e.g. Electricity, Wifi, Rent',
              controller: _nameController,
              errorText: _nameError,
              onChanged: (val) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),

            const SizedBox(height: AppSpacing.m),

            MMTextField(
              label: 'Amount (₹)',
              hint: 'e.g. 1850',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: _amountController,
              errorText: _amountError,
              onChanged: (val) {
                if (_amountError != null) setState(() => _amountError = null);
              },
            ),

            const SizedBox(height: AppSpacing.m),

            MMTextField(
              label: 'Due Date',
              hint: 'e.g. 24th of month or 2026-08-28',
              controller: _dueDateController,
            ),

            const SizedBox(height: AppSpacing.m),

            Text('Category', style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.s),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                fillColor: AppColors.surfaceContainerLow,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),

            const SizedBox(height: AppSpacing.m),

            Text('Payment Frequency', style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: 8,
              children: _frequencies.map((freq) {
                final sel = _frequency == freq;
                return ChoiceChip(
                  label: Text(freq),
                  selected: sel,
                  selectedColor: AppColors.primaryContainer,
                  labelStyle: TextStyle(color: sel ? AppColors.primary : AppColors.onSurface),
                  onSelected: (val) {
                    if (val) setState(() => _frequency = freq);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.m),

            Text('Payment Method', style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.s),
            DropdownButtonFormField<String>(
              initialValue: wallets.isNotEmpty ? wallets.first.name : _paymentMethod,
              decoration: InputDecoration(
                fillColor: AppColors.surfaceContainerLow,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              items: (wallets.isNotEmpty
                      ? wallets.map((w) => w.name).toList()
                      : ['UPI', 'HDFC Bank Account', 'Debit Card', 'Credit Card', 'Cash'])
                  .map((pm) => DropdownMenuItem(value: pm, child: Text(pm)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _paymentMethod = val);
              },
            ),

            const SizedBox(height: AppSpacing.stackLg),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.m),

            Text(
              'Automation & Reminders',
              style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.s),

            CheckboxListTile(
              title: const Text('1 day before due date'),
              value: _reminder1Day,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _reminder1Day = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('2 days before due date'),
              value: _reminder2Days,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _reminder2Days = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('On due date'),
              value: _reminderOnDue,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _reminderOnDue = val ?? false),
            ),

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: 'Create Bill Reminder',
              onPressed: _saveBill,
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
