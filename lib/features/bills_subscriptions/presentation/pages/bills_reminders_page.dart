import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_empty_state.dart';
import '../providers/bills_provider.dart';

/// Stitch Screen 6 — Bills & Reminders Overview Screen
class BillsRemindersPage extends ConsumerStatefulWidget {
  const BillsRemindersPage({super.key});

  @override
  ConsumerState<BillsRemindersPage> createState() => _BillsRemindersPageState();
}

class _BillsRemindersPageState extends ConsumerState<BillsRemindersPage> {
  String _selectedFilter = 'Upcoming';

  final List<String> _filters = const ['Upcoming', 'Paid', 'All'];

  @override
  Widget build(BuildContext context) {
    final bills = ref.watch(billsProvider);

    final upcomingBills = bills.where((b) => b.status != 'Paid').toList();

    final double totalUpcoming = upcomingBills.fold(0.0, (sum, b) => sum + b.amount);

    final filteredList = bills.where((b) {
      if (_selectedFilter == 'Upcoming') return b.status != 'Paid';
      if (_selectedFilter == 'Paid') return b.status == 'Paid';
      return true;
    }).toList();

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
          'Bills & Reminders',
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
            // Top Header Subtitle & Banner matching Stitch
            Text(
              'Stay on top of your upcoming payments.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),

            const SizedBox(height: AppSpacing.m),

            // Highlight Card for Upcoming Bills
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL UPCOMING BILLS',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onPrimaryContainer,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${totalUpcoming.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: AppTypography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${upcomingBills.length} upcoming ${upcomingBills.length == 1 ? 'bill' : 'bills'} scheduled',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.onPrimaryContainer.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // Filter Chips Row and Add Bill CTA
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: _selectedFilter == f,
                            selectedColor: AppColors.primaryContainer,
                            labelStyle: TextStyle(
                              color: _selectedFilter == f ? AppColors.primary : AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedFilter = f);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push(AppRoutes.addBill),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('+ Add Bill'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.m),

            // List of Bills or Authentic Empty State
            if (filteredList.isEmpty) ...[
              const SizedBox(height: AppSpacing.stackLg),
              MMEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No Bills Found',
                subtitle: _selectedFilter == 'Paid'
                    ? 'No paid bill history recorded yet.'
                    : 'You have no scheduled upcoming bills. Tap below to create your first bill reminder.',
                actionLabel: 'Add New Bill',
                onAction: () => context.push(AppRoutes.addBill),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (context, index) {
                  final bill = filteredList[index];
                  final isPaid = bill.status == 'Paid';

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isPaid ? AppColors.secondaryContainer : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.m),
                          ),
                          child: Icon(
                            isPaid ? Icons.check_circle_outline : Icons.calendar_month_outlined,
                            color: isPaid ? AppColors.onSecondaryContainer : AppColors.primary,
                          ),
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
                              const SizedBox(height: 2),
                              Text(
                                '${bill.category} • Due ${bill.dueDate}',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${bill.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            if (!isPaid)
                              InkWell(
                                onTap: () {
                                  ref.read(billsProvider.notifier).recordPayment(
                                        bill.id,
                                        BillPaymentRecord(
                                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                                          billId: bill.id,
                                          amount: bill.amount,
                                          paymentDate: DateTime.now(),
                                          paymentMethod: bill.paymentMethod,
                                          transactionId: 'tx_${bill.id}',
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Marked ${bill.name} as paid!'), backgroundColor: AppColors.primary),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text(
                                    'Pay Now',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            else
                              const MMStatusChip(
                                label: 'Paid',
                                backgroundColor: AppColors.secondaryContainer,
                                textColor: AppColors.onSecondaryContainer,
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
