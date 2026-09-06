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

/// Screen 1 — Bill Details Page
class BillDetailsPage extends ConsumerWidget {
  final String? id;

  const BillDetailsPage({
    super.key,
    this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);

    final bill = bills.firstWhere(
      (b) => b.id == id,
      orElse: () => BillItem(
        id: '',
        name: '',
        category: '',
        amount: 0,
        dueDate: '',
        frequency: '',
        paymentMethod: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );


    if (bill.id.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
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
            'Bill Details',
            style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: MMEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No Bill Details Found',
            subtitle: 'There is no active bill with this identifier. Add a bill to start tracking due dates.',
            actionLabel: 'Add a Bill',
            onAction: () => context.push(AppRoutes.addBill),
          ),
        ),
      );
    }

    final String statusLabel = bill.status;
    Color statusBg = AppColors.primaryContainer;
    Color statusTextColor = AppColors.primary;
    if (statusLabel == 'Paid') {
      statusBg = const Color(0xFFD1FAE5);
      statusTextColor = const Color(0xFF065F46);
    } else if (statusLabel == 'Overdue' || statusLabel == 'Due Soon') {
      statusBg = AppColors.tertiaryContainer;
      statusTextColor = AppColors.onTertiaryContainer;
    } else if (statusLabel == 'Paused') {
      statusBg = AppColors.surfaceContainerLow;
      statusTextColor = AppColors.onSurfaceVariant;
    }

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
          'Bill Details',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              ref.read(billsProvider.notifier).deleteBill(bill.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bill "${bill.name}" deleted.')),
              );
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.bills);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Header Identity Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.l),
                            ),
                            child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.name,
                                style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                bill.category,
                                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      MMStatusChip(
                        label: statusLabel,
                        backgroundColor: statusBg,
                        textColor: statusTextColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.l),

                  Text(
                    'BILL AMOUNT',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${bill.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: AppTypography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.m),
                  const Divider(color: AppColors.outlineVariant),
                  const SizedBox(height: AppSpacing.m),

                  _buildDetailRow('Due Date', bill.dueDate),
                  const Divider(color: AppColors.outlineVariant),
                  _buildDetailRow('Frequency', bill.frequency),
                  const Divider(color: AppColors.outlineVariant),
                  _buildDetailRow('Payment Method', bill.paymentMethod),
                  const Divider(color: AppColors.outlineVariant),
                  _buildDetailRow('Reminder Status', bill.reminderEnabled ? 'Enabled (${bill.reminderTime})' : 'Disabled'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.stackLg),

            // Payment History Section
            Text(
              'Payment History',
              style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.m),

            if (bill.paymentHistory.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                ),
                child: Text(
                  'No payment history recorded for this bill yet.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ] else ...[
              ...bill.paymentHistory.map((rec) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid via ${rec.paymentMethod}',
                            style: AppTypography.headlineMedium.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${rec.paymentDate.day}/${rec.paymentDate.month}/${rec.paymentDate.year}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Text(
                        '₹${rec.amount.toInt()}',
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: AppSpacing.stackLg),

            // Actions Buttons
            if (bill.status != 'Paid')
              MMButton(
                label: 'Mark as Paid',
                icon: Icons.check_circle_outline,
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
                      content: Text('Bill "${bill.name}" marked as Paid!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),

            const SizedBox(height: AppSpacing.m),

            Row(
              children: [
                Expanded(
                  child: MMButton(
                    label: bill.status == 'Paused' ? 'Resume Bill' : 'Pause Bill',
                    type: MMButtonType.secondary,
                    onPressed: () {
                      final nextStatus = bill.status == 'Paused' ? 'Upcoming' : 'Paused';
                      ref.read(billsProvider.notifier).updateBillStatus(bill.id, nextStatus);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bill status updated to $nextStatus.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: MMButton(
                    label: 'Delete Bill',
                    type: MMButtonType.secondary,
                    onPressed: () {
                      ref.read(billsProvider.notifier).deleteBill(bill.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bill "${bill.name}" removed.')),
                      );
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.bills);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
