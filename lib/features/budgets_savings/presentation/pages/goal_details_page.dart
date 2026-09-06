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
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../../core/widgets/mm_text_field.dart';
import '../providers/goals_provider.dart';

/// Screen 4 — Savings Goal Details Page
class GoalDetailsPage extends ConsumerStatefulWidget {
  final String? id;

  const GoalDetailsPage({
    super.key,
    this.id,
  });

  @override
  ConsumerState<GoalDetailsPage> createState() => _GoalDetailsPageState();
}

class _GoalDetailsPageState extends ConsumerState<GoalDetailsPage> {
  final TextEditingController _contribAmountController = TextEditingController();
  final TextEditingController _contribNoteController = TextEditingController();

  @override
  void dispose() {
    _contribAmountController.dispose();
    _contribNoteController.dispose();
    super.dispose();
  }

  void _openAddMoneyModal(GoalItem goal) {
    _contribAmountController.text = '';
    _contribNoteController.text = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.l,
            right: AppSpacing.l,
            top: AppSpacing.l,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Money to ${goal.name}',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),
              MMTextField(
                label: 'Contribution Amount (₹)',
                hint: 'e.g. 5000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _contribAmountController,
              ),
              const SizedBox(height: AppSpacing.m),
              MMTextField(
                label: 'Note (Optional)',
                hint: 'e.g. Monthly allocation',
                controller: _contribNoteController,
              ),
              const SizedBox(height: AppSpacing.l),
              MMButton(
                label: 'Add Contribution',
                onPressed: () {
                  final amtStr = _contribAmountController.text.trim();
                  final amt = double.tryParse(amtStr);
                  if (amt != null && amt > 0) {
                    ref.read(goalsProvider.notifier).addContribution(
                          goal.id,
                          amt,
                          note: _contribNoteController.text.trim(),
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ₹${amt.toInt()} to ${goal.name}!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);

    final goal = goals.firstWhere(
      (g) => g.id == widget.id,
      orElse: () => GoalItem(
        id: '',
        name: '',
        targetAmount: 0,
        savedAmount: 0,
        targetDate: '',
        category: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );


    if (goal.id.isEmpty) {
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
                context.go(AppRoutes.goals);
              }
            },
          ),
          title: Text(
            'Goal Details',
            style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: MMEmptyState(
            icon: Icons.savings_outlined,
            title: 'No Savings Goals Yet',
            subtitle: 'You have not created any savings goal yet. Set target amounts and deadline dates to start tracking progress.',
            actionLabel: 'Create a Goal',
            onAction: () => context.push(AppRoutes.smartPlanner),
          ),
        ),
      );
    }

    final double pct = goal.progressPercentage;

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
              context.go(AppRoutes.goals);
            }
          },
        ),
        title: Text(
          'Goal Details',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              ref.read(goalsProvider.notifier).deleteGoal(goal.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Goal "${goal.name}" deleted.')),
              );
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.goals);
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
            // Goal Identity Card
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
                            child: const Icon(Icons.savings, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: AppSpacing.m),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.name,
                                style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                goal.category,
                                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      MMStatusChip(
                        label: goal.status,
                        backgroundColor: goal.status == 'Completed' ? const Color(0xFFD1FAE5) : AppColors.primaryContainer,
                        textColor: goal.status == 'Completed' ? const Color(0xFF065F46) : AppColors.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.l),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AMOUNT SAVED', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                          const SizedBox(height: 2),
                          Text(
                            '₹${goal.savedAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: AppTypography.display.copyWith(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('TARGET AMOUNT', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                          const SizedBox(height: 2),
                          Text(
                            '₹${goal.targetAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: AppTypography.headlineMedium.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.m),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: AppTypography.bodyMedium),
                      Text('${pct.toStringAsFixed(1)}%', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  MMProgressBar(
                    progress: (pct / 100).clamp(0.0, 1.0),
                    color: const Color(0xFF10B981),
                  ),

                  const SizedBox(height: AppSpacing.m),
                  const Divider(color: AppColors.outlineVariant),
                  const SizedBox(height: AppSpacing.m),

                  _buildDetailRow('Remaining Amount', '₹${goal.remainingAmount.toInt()}'),
                  const Divider(color: AppColors.outlineVariant),
                  _buildDetailRow('Target Date', goal.targetDate),
                  const Divider(color: AppColors.outlineVariant),
                  _buildDetailRow('Priority Level', goal.priority),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.stackLg),

            // Add Money CTA Button
            MMButton(
              label: 'Add Money',
              icon: Icons.add,
              onPressed: () => _openAddMoneyModal(goal),
            ),

            const SizedBox(height: AppSpacing.stackLg),

            // Contribution History Section
            Text(
              'Contribution History',
              style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.m),

            if (goal.contributions.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                ),
                child: Text(
                  'No contribution history recorded for this goal yet.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ] else ...[
              ...goal.contributions.map((c) {
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
                            c.note.isNotEmpty ? c.note : 'Goal Allocation',
                            style: AppTypography.headlineMedium.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${c.date.day}/${c.date.month}/${c.date.year}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Text(
                        '+₹${c.amount.toInt()}',
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
