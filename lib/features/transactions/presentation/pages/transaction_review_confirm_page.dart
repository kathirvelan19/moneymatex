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
import '../../../accounts/presentation/providers/user_wallets_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';

/// Page 5 — Transaction Review & Confirmation Screen
class TransactionReviewConfirmPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;

  const TransactionReviewConfirmPage({
    super.key,
    this.initialData,
  });

  @override
  ConsumerState<TransactionReviewConfirmPage> createState() => _TransactionReviewConfirmPageState();
}

class _TransactionReviewConfirmPageState extends ConsumerState<TransactionReviewConfirmPage> {
  bool _isSaving = false;

  Future<void> _confirmAndSaveTransaction() async {
    final data = widget.initialData ?? {};

    final String title = (data['title'] as String?)?.trim().isNotEmpty == true
        ? data['title']
        : 'Expense';
    final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final String category = (data['category'] as String?)?.trim().isNotEmpty == true
        ? data['category']
        : 'General';
    final String wallet = (data['wallet'] as String?)?.trim().isNotEmpty == true
        ? data['wallet']
        : 'Primary Account';
    final bool isExpense = data['isExpense'] as bool? ?? true;
    final String source = data['source'] as String? ?? 'manual';
    final String? notes = data['notes'] as String?;
    final double? ocrConfidence = (data['ocrConfidence'] as num?)?.toDouble();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save transaction with zero or negative amount.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final newTransaction = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      amount: amount,
      wallet: wallet,
      paymentMethod: source == 'ocr' ? 'Receipt Scan' : (source == 'automatic_tracking' ? 'UPI Auto-Detect' : 'Manual'),
      date: DateTime.now(),
      notes: notes,
      isExpense: isExpense,
      icon: TransactionsNotifier.getCategoryIcon(category),
      source: source,
      ocrConfidence: ocrConfidence,
      needsConfirmation: false,
    );

    // 1. Save transaction in transactionsProvider
    await ref.read(transactionsProvider.notifier).addTransaction(newTransaction);

    // 2. Update wallet balance if applicable
    ref.read(userWalletsProvider.notifier).updateBalance(
          wallet,
          isExpense ? -amount : amount,
        );

    // 3. FinancialAnalyticsService automatically recalculates summary via Riverpod ref watch

    if (mounted) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction saved: $title — ₹${amount.toInt()}'),
          backgroundColor: AppColors.primary,
        ),
      );

      context.go(AppRoutes.transactions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.initialData ?? {};

    final String title = data['title']?.toString().trim().isNotEmpty == true ? data['title'].toString() : 'Not provided';
    final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final String category = data['category']?.toString().trim().isNotEmpty == true ? data['category'].toString() : 'Not provided';
    final String wallet = data['wallet']?.toString().trim().isNotEmpty == true ? data['wallet'].toString() : 'Not provided';
    final bool isExpense = data['isExpense'] as bool? ?? true;
    final String source = data['source']?.toString() ?? 'manual';

    final String displaySource = source == 'ocr'
        ? 'Receipt Scan'
        : (source == 'automatic_tracking' ? 'Automatic Tracking' : 'Manual Entry');

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
          'Review Transaction',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please review your final transaction details before confirming.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            // Summary Card (Displays ONLY actual values, NO fabricated data!)
            Container(
              width: double.infinity,
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
                      MMStatusChip(
                        label: isExpense ? 'Expense' : 'Income',
                        backgroundColor: isExpense ? AppColors.primaryContainer : AppColors.secondaryContainer,
                        textColor: isExpense ? AppColors.primary : AppColors.onSecondaryContainer,
                      ),
                      MMStatusChip(
                        label: displaySource,
                        backgroundColor: AppColors.surfaceContainerLow,
                        textColor: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.l),

                  Text(
                    'AMOUNT',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amount > 0 ? '₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}' : 'Not provided',
                    style: AppTypography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isExpense ? AppColors.onSurface : const Color(0xFF10B981),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.l),
                  const Divider(color: AppColors.outlineVariant),
                  const SizedBox(height: AppSpacing.m),

                  _buildReviewRow('Merchant / Description', title),
                  const Divider(color: AppColors.outlineVariant),
                  _buildReviewRow('Category', category),
                  const Divider(color: AppColors.outlineVariant),
                  _buildReviewRow('Account / Wallet', wallet),
                  const Divider(color: AppColors.outlineVariant),
                  _buildReviewRow('Source', displaySource),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.stackLg),

            // Confirm & Save CTA Button
            MMButton(
              label: _isSaving ? 'Saving...' : 'Confirm & Save',
              onPressed: _isSaving ? () {} : _confirmAndSaveTransaction,
            ),


            const SizedBox(height: AppSpacing.m),

            // Edit Back Action
            Center(
              child: TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.transactions);
                  }
                },
                child: Text(
                  'Edit Details',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
