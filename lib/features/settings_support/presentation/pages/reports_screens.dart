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
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../../core/widgets/mm_section_header.dart';
import '../../../../features/auth_onboarding/presentation/providers/user_profile_provider.dart';

import '../../../../features/transactions/presentation/providers/transactions_provider.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';
import '../../../../features/budgets_savings/presentation/providers/goals_provider.dart';

String _formatCurrency(num amount) {
  final str = amount.toStringAsFixed(0);
  final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$result';
}

/// Stitch Screen 10: MoneyMateX Reports & Analytics Overview (51dbf8bbf1e94044870b74ddab643c3e)
/// Accessed via More Menu -> Reports & Analytics
class ReportsOverviewPage extends ConsumerStatefulWidget {
  const ReportsOverviewPage({super.key});

  @override
  ConsumerState<ReportsOverviewPage> createState() => _ReportsOverviewPageState();
}

class _ReportsOverviewPageState extends ConsumerState<ReportsOverviewPage> {
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
    final goals = ref.watch(goalsProvider);

    final filteredTransactions = _filterTransactions(allTransactions, _selectedRange);

    final expenseTransactions = filteredTransactions.where((t) => t.isExpense).toList();
    final incomeTransactions = filteredTransactions.where((t) => !t.isExpense).toList();

    final double totalExpenses = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double loggedIncome = incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double userIncome = userProfile.monthlyIncome;
    final double totalIncome = loggedIncome > 0 ? loggedIncome : userIncome;
    final double netSavings = totalIncome - totalExpenses;
    final double savingsRate = totalIncome > 0 ? ((netSavings / totalIncome) * 100).clamp(0.0, 100.0) : 0.0;

    // Category spending breakdown calculated strictly from transactions
    final Map<String, double> categoryTotals = {};
    for (final t in expenseTransactions) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0.0) + t.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Monthly spending breakdown calculated from transactions
    final Map<String, double> monthlyTotals = {};
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    for (final t in expenseTransactions) {
      final key = '${months[t.date.month - 1]} ${t.date.year}';
      monthlyTotals[key] = (monthlyTotals[key] ?? 0.0) + t.amount;
    }

    final totalSavedGoals = goals.fold<double>(0.0, (sum, g) => sum + g.savedAmount);
    final totalTargetGoals = goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);

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
          'Reports & Analytics',
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
                  // Range Filter Chips
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

                  if (filteredTransactions.isEmpty) ...[
                    // Empty State for Fresh User or Empty Filter Range
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
                          const Icon(Icons.pie_chart_outline, size: 52, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            allTransactions.isEmpty
                                ? 'No Transaction Data Recorded Yet'
                                : 'No Transactions in "$_selectedRange"',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            allTransactions.isEmpty
                                ? 'Log transactions, scan receipts, or pay bills to generate real-time financial analytics and category breakdowns.'
                                : 'Try changing the time range filter or log new transactions to see spending analytics.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          MMButton(
                            label: '+ Log First Transaction',
                            onPressed: () => context.go(AppRoutes.addExpense),
                            type: MMButtonType.primary,
                            fullWidth: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ] else ...[
                    // Financial Overview Summary Card
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
                              Text('NET CASHFLOW SUMMARY', style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8)),
                              MMStatusChip(
                                label: '${savingsRate.toStringAsFixed(1)}% Saved',
                                backgroundColor: const Color(0xFFE8F5E9),
                                textColor: const Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            _formatCurrency(netSavings),
                            style: AppTypography.display.copyWith(
                              color: netSavings >= 0 ? const Color(0xFF2E7D32) : AppColors.error,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('TOTAL INCOME', style: AppTypography.labelSmall),
                                    Text(
                                      _formatCurrency(totalIncome),
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(height: 36, width: 1, color: AppColors.outlineVariant),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('TOTAL EXPENSES', style: AppTypography.labelSmall),
                                    Text(
                                      _formatCurrency(totalExpenses),
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
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

                    // Income vs Expense Spent Ratio
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
                              Text('INCOME SPENT RATIO', style: AppTypography.labelSmall),
                              Text(
                                totalIncome > 0 ? '${((totalExpenses / totalIncome) * 100).toStringAsFixed(1)}%' : '0%',
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          MMProgressBar(
                            progress: totalIncome > 0 ? (totalExpenses / totalIncome).clamp(0.0, 1.0) : 0.0,
                            height: 8,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.stackLg),

                    // Category Spending Breakdown
                    MMSectionHeader(
                      title: 'Category Spending Distribution',
                      subtitle: 'Calculated from ${expenseTransactions.length} expense transactions',
                    ),
                    const SizedBox(height: AppSpacing.s),

                    ...sortedCategories.map((entry) {
                      final category = entry.key;
                      final amount = entry.value;
                      final percentage = totalExpenses > 0 ? (amount / totalExpenses * 100) : 0.0;

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
                                Text(category, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  '${_formatCurrency(amount)} (${percentage.toStringAsFixed(1)}%)',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            MMProgressBar(progress: (percentage / 100).clamp(0.0, 1.0), height: 6),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.stackLg),

                    // Monthly Spending Breakdown Visual Bars (if multiple months exist)
                    if (monthlyTotals.isNotEmpty) ...[
                      const MMSectionHeader(
                        title: 'Monthly Spending Trend',
                        subtitle: 'Calculated expense breakdown by month',
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
                            ...monthlyTotals.entries.map((m) {
                              final monthLabel = m.key;
                              final monthAmt = m.value;
                              final monthRatio = totalExpenses > 0 ? (monthAmt / totalExpenses).clamp(0.0, 1.0) : 0.0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(monthLabel, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                        Text(_formatCurrency(monthAmt), style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    MMProgressBar(progress: monthRatio, height: 6, color: AppColors.secondary),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackLg),
                    ],
                  ],

                  // Goals Portfolio Performance Summary (if goals exist)
                  if (goals.isNotEmpty) ...[
                    const MMSectionHeader(
                      title: 'Goals Portfolio Analytics',
                      subtitle: 'Summary of active goal savings',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${goals.length} Goals Active', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                '${_formatCurrency(totalSavedGoals)} / ${_formatCurrency(totalTargetGoals)}',
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          MMProgressBar(
                            progress: totalTargetGoals > 0 ? (totalSavedGoals / totalTargetGoals).clamp(0.0, 1.0) : 0.0,
                            height: 6,
                            color: AppColors.tertiary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  MMButton(
                    label: '+ Add New Expense',
                    onPressed: () => context.go(AppRoutes.addExpense),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'View All Transactions',
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
}

class ReportsDetailedPage extends StatelessWidget {
  const ReportsDetailedPage({super.key});
  @override
  Widget build(BuildContext context) => const ReportsOverviewPage();
}

class ReportsSummaryPage extends StatelessWidget {
  const ReportsSummaryPage({super.key});
  @override
  Widget build(BuildContext context) => const ReportsOverviewPage();
}

class ReportsCompactPage extends StatelessWidget {
  const ReportsCompactPage({super.key});
  @override
  Widget build(BuildContext context) => const ReportsOverviewPage();
}

class ReportsAnimatedPage extends StatelessWidget {
  const ReportsAnimatedPage({super.key});
  @override
  Widget build(BuildContext context) => const ReportsOverviewPage();
}

class ReportGeneratorPage extends StatelessWidget {
  const ReportGeneratorPage({super.key});
  @override
  Widget build(BuildContext context) => const ReportsOverviewPage();
}
