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
import '../providers/bills_provider.dart';

/// Screen 3 — Upcoming / Scheduled Payments Page
class UpcomingPaymentsPage extends ConsumerStatefulWidget {
  const UpcomingPaymentsPage({super.key});

  @override
  ConsumerState<UpcomingPaymentsPage> createState() => _UpcomingPaymentsPageState();
}

class _UpcomingPaymentsPageState extends ConsumerState<UpcomingPaymentsPage> {
  String _selectedFilter = 'All'; // 'All', 'Due Soon', 'Upcoming', 'Overdue'

  @override
  Widget build(BuildContext context) {
    final bills = ref.watch(billsProvider);

    final upcomingBills = bills.where((b) => b.status != 'Paid').toList();

    List<BillItem> filteredBills = upcomingBills;
    if (_selectedFilter == 'Due Soon') {
      filteredBills = upcomingBills.where((b) => b.status == 'Due Soon').toList();
    } else if (_selectedFilter == 'Upcoming') {
      filteredBills = upcomingBills.where((b) => b.status == 'Upcoming').toList();
    } else if (_selectedFilter == 'Overdue') {
      filteredBills = upcomingBills.where((b) => b.status == 'Overdue').toList();
    }

    final double totalUpcomingAmount = upcomingBills.fold(0.0, (sum, b) => sum + b.amount);

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
          'Upcoming Payments',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => context.push(AppRoutes.addBill),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL UPCOMING DUE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      MMStatusChip(
                        label: '${upcomingBills.length} Bills Pending',
                        backgroundColor: AppColors.surfaceContainerLowest,
                        textColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${totalUpcomingAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: AppTypography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // Filter Chips (All, Due Soon, Upcoming, Overdue)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Due Soon', 'Upcoming', 'Overdue'].map((f) {
                  final sel = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: sel,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: sel ? AppColors.primary : AppColors.onSurface,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = f);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // Upcoming Bills List or Authentic Empty State
            if (filteredBills.isEmpty) ...[
              MMEmptyState(
                icon: Icons.event_available_outlined,
                title: 'No Upcoming Payments',
                subtitle: _selectedFilter == 'All'
                    ? 'You have no pending bill payments. Set up recurring bill reminders to track payments.'
                    : 'No payments found matching the "$_selectedFilter" filter.',
                actionLabel: 'Add a Bill',
                onAction: () => context.push(AppRoutes.addBill),
              ),
            ] else ...[
              ...filteredBills.map((bill) {
                Color statusBg = AppColors.primaryContainer;
                Color statusTextColor = AppColors.primary;
                if (bill.status == 'Overdue' || bill.status == 'Due Soon') {
                  statusBg = AppColors.tertiaryContainer;
                  statusTextColor = AppColors.onTertiaryContainer;
                }

                return InkWell(
                  onTap: () => context.push('/bills/details/${bill.id}'),
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.m),
                              ),
                              child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bill.name,
                                    style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Due ${bill.dueDate} • ${bill.paymentMethod}',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${bill.amount.toInt()}',
                                  style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                MMStatusChip(
                                  label: bill.status,
                                  backgroundColor: statusBg,
                                  textColor: statusTextColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                ref.read(billsProvider.notifier).updateBillStatus(bill.id, 'Paused');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Bill "${bill.name}" paused.')),
                                );
                              },
                              child: const Text('Pause'),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            MMButton(
                              label: 'Mark as Paid',
                              fullWidth: false,
                              onPressed: () {
                                final record = BillPaymentRecord(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  billId: bill.id,
                                  amount: bill.amount,
                                  paymentDate: DateTime.now(),
                                  paymentMethod: bill.paymentMethod,
                                  transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
                                );
                                ref.read(billsProvider.notifier).recordPayment(bill.id, record);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Marked "${bill.name}" as Paid!'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: 'Add New Bill',
              icon: Icons.add,
              onPressed: () => context.push(AppRoutes.addBill),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
