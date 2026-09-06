import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_ai_insight_card.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_empty_state.dart';
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../../core/widgets/mm_section_header.dart';
import '../../../auth_onboarding/presentation/providers/user_profile_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

String _formatCurrency(num amount) {
  final str = amount.toStringAsFixed(0);
  final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$result';
}

/// Stitch Screen: MoneyMateX Detailed Income & Cash Flow Analytics Screen
/// Navigation: More → Income & Cash Flow OR Dashboard → Cash Flow
class CashFlowAnalysisPage extends ConsumerStatefulWidget {
  const CashFlowAnalysisPage({super.key});

  @override
  ConsumerState<CashFlowAnalysisPage> createState() => _CashFlowAnalysisPageState();
}

class _CashFlowAnalysisPageState extends ConsumerState<CashFlowAnalysisPage> {
  String _selectedRange = 'This Month';
  final List<String> _ranges = const ['This Month', 'Last 3 Months', 'Year to Date', 'All Time'];

  List<TransactionItem> _filterTransactions(List<TransactionItem> all, String range) {
    final now = DateTime.now();
    switch (range) {
      case 'This Month':
        return all.where((t) => t.date.year == now.year && t.date.month == now.month).toList();
      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return all.where((t) => t.date.isAfter(threeMonthsAgo)).toList();
      case 'Year to Date':
        return all.where((t) => t.date.year == now.year).toList();
      case 'All Time':
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionsProvider);
    final userProfile = ref.watch(userProfileProvider);

    final filteredTransactions = _filterTransactions(allTransactions, _selectedRange);

    final expenseTransactions = filteredTransactions.where((t) => t.isExpense).toList();
    final incomeTransactions = filteredTransactions.where((t) => !t.isExpense).toList();

    final double totalExpenses = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double loggedIncome = incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double userIncome = userProfile.monthlyIncome;
    final double totalIncome = loggedIncome > 0 ? loggedIncome : userIncome;
    final double netCashFlow = totalIncome - totalExpenses;

    // Income sources breakdown
    final Map<String, double> incomeSources = {};
    for (final t in incomeTransactions) {
      incomeSources[t.category] = (incomeSources[t.category] ?? 0.0) + t.amount;
    }
    if (incomeSources.isEmpty && userIncome > 0) {
      incomeSources['Monthly Salary'] = userIncome;
    }

    final sortedIncomeSources = incomeSources.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Category expense breakdown
    final Map<String, double> expenseCategories = {};
    for (final t in expenseTransactions) {
      expenseCategories[t.category] = (expenseCategories[t.category] ?? 0.0) + t.amount;
    }

    final sortedExpenses = expenseCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: Text(
          'Income & Cash Flow',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Money / Income',
            onPressed: () => context.go(AppRoutes.addMoney),
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
                  // Range Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _ranges.map((r) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: r,
                            isSelected: _selectedRange == r,
                            onSelected: () => setState(() => _selectedRange = r),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  if (filteredTransactions.isEmpty && totalIncome == 0) ...[
                    MMEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No Cash Flow Data Recorded Yet',
                      subtitle: 'Add income or log expenses to generate your detailed cash flow statement.',
                      actionLabel: '+ Deposit Money',
                      onAction: () => context.go(AppRoutes.addMoney),
                    ),
                  ] else ...[
                    // Net Cash Flow Summary Banner Card
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
                              Text('NET CASH FLOW', style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8)),
                              MMStatusChip(
                                label: netCashFlow >= 0 ? 'Surplus' : 'Deficit',
                                backgroundColor: netCashFlow >= 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                textColor: netCashFlow >= 0 ? const Color(0xFF2E7D32) : AppColors.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            _formatCurrency(netCashFlow),
                            style: AppTypography.display.copyWith(
                              color: netCashFlow >= 0 ? const Color(0xFF2E7D32) : AppColors.error,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Net Cash Flow = Total Income (${_formatCurrency(totalIncome)}) - Total Expenses (${_formatCurrency(totalExpenses)})',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
                          ),
                          const SizedBox(height: AppSpacing.m),

                          // Income vs Expense Metrics Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(AppRadius.l),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('TOTAL INCOME', style: AppTypography.labelSmall.copyWith(color: const Color(0xFF2E7D32))),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(totalIncome),
                                        style: AppTypography.headlineMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2E7D32),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(AppRadius.l),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('TOTAL EXPENSES', style: AppTypography.labelSmall.copyWith(color: AppColors.error)),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(totalExpenses),
                                        style: AppTypography.headlineMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.error,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.stackLg),

                    // Income Sources Breakdown Section
                    MMSectionHeader(
                      title: 'Income Sources',
                      subtitle: '${sortedIncomeSources.length} active income sources',
                      actionLabel: '+ Add Income',
                      onAction: () => context.go(AppRoutes.addMoney),
                    ),
                    const SizedBox(height: AppSpacing.s),

                    if (sortedIncomeSources.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No income sources logged yet for this period. Tap "+ Add Income" above.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      )
                    else
                      ...sortedIncomeSources.map((entry) {
                        final sourceName = entry.key;
                        final amount = entry.value;
                        final ratio = totalIncome > 0 ? (amount / totalIncome) : 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.stackSm),
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
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_downward, color: Color(0xFF2E7D32), size: 20),
                                      const SizedBox(width: 8),
                                      Text(sourceName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Text(
                                    '${_formatCurrency(amount)} (${(ratio * 100).toStringAsFixed(1)}%)',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              MMProgressBar(progress: ratio.clamp(0.0, 1.0), height: 6, color: const Color(0xFF2E7D32)),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: AppSpacing.stackLg),

                    // Expense Outflow Breakdown Section
                    if (sortedExpenses.isNotEmpty) ...[
                      const MMSectionHeader(
                        title: 'Expense Outflows',
                        subtitle: 'Calculated spending per category',
                      ),
                      const SizedBox(height: AppSpacing.s),

                      ...sortedExpenses.map((entry) {
                        final catName = entry.key;
                        final amount = entry.value;
                        final ratio = totalExpenses > 0 ? (amount / totalExpenses) : 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.stackSm),
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
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward, color: AppColors.error, size: 20),
                                      const SizedBox(width: 8),
                                      Text(catName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Text(
                                    '${_formatCurrency(amount)} (${(ratio * 100).toStringAsFixed(1)}%)',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              MMProgressBar(progress: ratio.clamp(0.0, 1.0), height: 6, color: AppColors.error),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: AppSpacing.stackLg),
                    ],

                    // MoneyMateX Insights
                    MMAIInsightCard(
                      title: 'MoneyMateX Cash Flow Insights',
                      description: netCashFlow >= 0
                          ? 'Positive net cash flow of ${_formatCurrency(netCashFlow)}! Consider transferring surplus capital into your active savings goals.'
                          : 'Your expenses exceed income by ${_formatCurrency(netCashFlow.abs())} for this period. Review high spending categories below.',
                      actionLabel: netCashFlow >= 0 ? 'Transfer to Savings Goal →' : 'Review Budget →',
                      onAction: netCashFlow >= 0
                          ? () => context.go(AppRoutes.goals)
                          : () => context.go(AppRoutes.budgetPerformance),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: MMPrimaryButton(
                          label: '+ Add Money',
                          onPressed: () => context.go(AppRoutes.addMoney),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: MMSecondaryButton(
                          label: '+ Add Expense',
                          onPressed: () => context.go(AppRoutes.addExpense),
                        ),
                      ),
                    ],
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
