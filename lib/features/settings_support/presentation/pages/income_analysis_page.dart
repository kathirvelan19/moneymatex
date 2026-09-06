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
import '../../../auth_onboarding/presentation/providers/user_profile_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

/// Stitch Batch — Income Analysis Page
class IncomeAnalysisPage extends ConsumerStatefulWidget {
  const IncomeAnalysisPage({super.key});

  @override
  ConsumerState<IncomeAnalysisPage> createState() => _IncomeAnalysisPageState();
}

class _IncomeAnalysisPageState extends ConsumerState<IncomeAnalysisPage> {
  String _selectedPeriod = 'This Month'; // 'This Week', 'This Month', 'Last Month', '3 Months'

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final profile = ref.watch(userProfileProvider);

    final now = DateTime.now();
    final incomeTransactions = transactions.where((t) {
      if (t.isExpense) return false;
      switch (_selectedPeriod) {
        case 'This Week':
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          return t.date.isAfter(sevenDaysAgo);
        case 'This Month':
          return t.date.year == now.year && t.date.month == now.month;
        case 'Last Month':
          final lastMonthDate = DateTime(now.year, now.month - 1, 1);
          return t.date.year == lastMonthDate.year && t.date.month == lastMonthDate.month;
        case '3 Months':
          final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
          return t.date.isAfter(threeMonthsAgo);
        default:
          return true;
      }
    }).toList();

    final double loggedIncome = incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double userIncome = profile.monthlyIncome > 0 ? profile.monthlyIncome : 0.0;
    final double totalIncome = loggedIncome > 0 ? loggedIncome : userIncome;

    final Map<String, double> incomeSources = {};
    for (final t in incomeTransactions) {
      incomeSources[t.category] = (incomeSources[t.category] ?? 0.0) + t.amount;
    }
    if (incomeSources.isEmpty && userIncome > 0) {
      incomeSources['Monthly Salary'] = userIncome;
    }

    final sortedIncomeSources = incomeSources.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          'Income Analysis',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed analysis of revenue streams and income categories.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            // Time Period Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['This Week', 'This Month', 'Last Month', '3 Months'].map((period) {
                  final sel = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: sel,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: sel ? AppColors.primary : AppColors.onSurface,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedPeriod = period);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            if (totalIncome == 0) ...[
              MMEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No Income Recorded Yet',
                subtitle: 'No income logged for $_selectedPeriod. Deposit money or set up your monthly income profile.',
                actionLabel: '+ Deposit Money',
                onAction: () => context.push(AppRoutes.addMoney),
              ),
            ] else ...[
              // Total Income Hero Card
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
                        Text(
                          'TOTAL INCOME ($_selectedPeriod)',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        MMStatusChip(
                          label: '${sortedIncomeSources.length} Income Sources',
                          backgroundColor: const Color(0xFFD1FAE5),
                          textColor: const Color(0xFF065F46),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      '₹${totalIncome.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: AppTypography.display.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.stackLg),

              // Income Sources List
              Text(
                'Income Streams',
                style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.m),

              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: sortedIncomeSources.map((entry) {
                    final pct = totalIncome > 0 ? (entry.value / totalIncome) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${entry.value.toInt()} (${(pct * 100).toStringAsFixed(1)}%)',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          MMProgressBar(
                            progress: pct.clamp(0.0, 1.0),
                            color: const Color(0xFF10B981),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: '+ Deposit Money',
              icon: Icons.add,
              onPressed: () => context.push(AppRoutes.addMoney),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
