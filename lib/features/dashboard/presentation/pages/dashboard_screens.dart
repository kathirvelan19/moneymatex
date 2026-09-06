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
import '../../../../core/widgets/mm_card.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../../core/widgets/mm_section_header.dart';
import '../../../../core/widgets/mm_transaction_tile.dart';
import '../../../../core/services/financial_analytics_service.dart';
import '../../../accounts/presentation/providers/user_wallets_provider.dart';
import '../../../auth_onboarding/presentation/providers/user_profile_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../widgets/command_center_chart.dart';
import '../widgets/compact_net_worth_chart.dart';
import '../widgets/detailed_net_worth_chart.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/spending_analysis_chart.dart';
import '../widgets/financial_alert_tile.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/spending_breakdown_card.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/saving_goal_card.dart';
import '../widgets/recent_transactions_card.dart';

/// Stitch Screen: MoneyMateX Main Financial Dashboard (a3fdf44abc214993be7b3ff7c049ba8f)
/// Main Financial Dashboard displaying overview cards, spending analytics, budget status, AI insights, goals, and recent transactions.
class MainDashboardPage extends ConsumerStatefulWidget {
  const MainDashboardPage({super.key});

  @override
  ConsumerState<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends ConsumerState<MainDashboardPage> {
  bool _isFabExpanded = false;

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final transactions = ref.watch(transactionsProvider);

    final double totalExpenses = transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);

    final double totalIncomeFromTx = transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);

    final double totalIncome = userProfile.totalIncome + totalIncomeFromTx;
    final double actualSpent = totalExpenses;
    final double availableThisMonth = totalIncome - actualSpent;
    final double budgetLimit = userProfile.monthlyExpensesEstimate > 0
        ? userProfile.monthlyExpensesEstimate
        : userProfile.totalIncome;

    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final int daysLeft = lastDay - now.day;

    final displayName = userProfile.name.isNotEmpty ? userProfile.name : 'User';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.s,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header & Available Money Hero Card
                  DashboardHeader(
                    userName: displayName,
                    availableAmount: availableThisMonth,
                    incomeAmount: totalIncome,
                    spentAmount: actualSpent,
                    onNotificationTap: () => context.go(AppRoutes.alerts),
                    onProfileTap: () => context.go(AppRoutes.financialProfile),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 2. Responsive Row: This Month & Budget Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 540;
                      final cardWidth = isWide
                          ? (constraints.maxWidth - AppSpacing.stackMd) / 2
                          : constraints.maxWidth;

                      return Wrap(
                        spacing: AppSpacing.stackMd,
                        runSpacing: AppSpacing.stackMd,
                        children: [
                          // Card A: This Month Summary Card
                          SizedBox(
                            width: cardWidth,
                            child: MonthlySummaryCard(
                              totalSpent: actualSpent,
                              budgetLimit: budgetLimit,
                              percentVsLastMonth: 0,
                              isUnderBudget: actualSpent <= budgetLimit,
                              onViewTransactions: () => context.go(AppRoutes.transactions),
                            ),
                          ),

                          // Card B: Budget Progress Card with Circular Ring
                          SizedBox(
                            width: cardWidth,
                            child: BudgetProgressCard(
                              budgetLimit: budgetLimit,
                              totalSpent: actualSpent,
                              daysLeft: daysLeft,
                              onViewBudget: () => context.go(AppRoutes.budgetPerformance),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 3. Where Your Money Goes Card (Driven 100% by user transactions)
                  SpendingBreakdownCard(
                    transactions: transactions,
                    onViewAnalysis: () => context.go(AppRoutes.spendingAnalysis),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 4. MoneyMateX AI Insight Card (Driven 100% by user spending)
                  AiInsightCard(
                    totalSpent: actualSpent,
                    budgetLimit: budgetLimit,
                    onViewInsight: () => context.go(AppRoutes.aiAssistant),
                    onAskAI: () => context.go(AppRoutes.aiChat),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 5. Saving Goal Card (Driven 100% by user profile goal)
                  SavingGoalCard(
                    goalTitle: userProfile.primaryGoal,
                    targetDate: '',
                    currentSaved: userProfile.currentSavings,
                    targetAmount: userProfile.goalTargetAmount,
                    onViewGoal: () => context.go(AppRoutes.goals),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 6. Recent Transactions / Empty State (Driven 100% by user transactions)
                  RecentTransactionsCard(
                    transactions: transactions,
                    onViewAll: () => context.go(AppRoutes.transactions),
                    onAddTransaction: () => context.go(AppRoutes.addExpense),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 7. Footer Utility Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 6),
                            Text(
                              'Smart tracking active',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurface,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tracking entries refreshed'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Text(
                                'Reset tracking',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• Last updated 5m ago',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabExpanded) ...[
            FloatingActionButton.extended(
              heroTag: 'scan_receipt',
              onPressed: () => context.go(AppRoutes.scanReceipt),
              label: const Text('Scan Receipt'),
              icon: const Icon(Icons.document_scanner_outlined),
              backgroundColor: AppColors.surfaceContainerLowest,
              foregroundColor: AppColors.onSurface,
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              heroTag: 'add_expense',
              onPressed: () => context.go(AppRoutes.addExpense),
              label: const Text('Add Expense'),
              icon: const Icon(Icons.remove_circle_outline),
              backgroundColor: AppColors.surfaceContainerLowest,
              foregroundColor: AppColors.onSurface,
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            heroTag: 'main_fab',
            onPressed: () => setState(() => _isFabExpanded = !_isFabExpanded),
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimaryContainer,
            child: Icon(_isFabExpanded ? Icons.close : Icons.add, size: 28),
          ),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Financial Command Center (5e3c0ff7910847e6898bfa050d24d93e)
class FinancialCommandCenterPage extends ConsumerStatefulWidget {
  const FinancialCommandCenterPage({super.key});

  @override
  ConsumerState<FinancialCommandCenterPage> createState() => _FinancialCommandCenterPageState();
}

class _FinancialCommandCenterPageState extends ConsumerState<FinancialCommandCenterPage> {
  String _selectedPeriod = '1M';
  String _selectedCategory = 'All';

  final List<String> _periods = const ['1D', '1W', '1M', '3M', '1Y', 'ALL'];
  final List<String> _categories = const ['All', 'Assets', 'Liabilities', 'Cash Flow'];

  String _formatCurrency(num amount) {
    final str = amount.toInt().toString();
    final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
    final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '₹$result';
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();
    final wallets = ref.watch(userWalletsProvider);
    final transactions = ref.watch(transactionsProvider);

    final double totalAssets = summary.totalWalletBalance + summary.totalGoalSaved;
    const double totalLiabilities = 0.0;
    final double netWorth = totalAssets - totalLiabilities;
    final double assetRatio = totalAssets > 0 ? (totalAssets / (totalAssets + totalLiabilities)).clamp(0.0, 1.0) : 1.0;

    final recentTransactions = transactions.take(5).toList();

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
          'Financial Command Center',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () => context.go(AppRoutes.alerts),
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
                  // Section 1: Hero Net Worth & Command Card
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
                              'COMMAND CENTER NET WORTH',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            MMStatusChip(
                              label: summary.hasData ? '${summary.savingsRate.toStringAsFixed(1)}% Saved' : 'No Data',
                              backgroundColor: const Color(0xFFE6F4EA),
                              textColor: const Color(0xFF137333),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          _formatCurrency(netWorth),
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL ASSETS', style: AppTypography.labelSmall),
                                  Text(
                                    _formatCurrency(totalAssets),
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.primaryContainer,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(height: 32, width: 1, color: AppColors.outlineVariant),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL LIABILITIES', style: AppTypography.labelSmall),
                                  Text(
                                    _formatCurrency(totalLiabilities),
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.error,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        MMProgressBar(progress: assetRatio, height: 8),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Asset Ratio: ${(assetRatio * 100).toInt()}%', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                            Text('Debt Ratio: ${(100 - (assetRatio * 100)).toInt()}%', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Command Metrics Grid
                  Text('Key Financial Metrics', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 540;
                      final cardWidth = isWide ? (constraints.maxWidth - AppSpacing.stackMd) / 2 : constraints.maxWidth;

                      return Wrap(
                        spacing: AppSpacing.stackMd,
                        runSpacing: AppSpacing.stackMd,
                        children: [
                          _buildMetricCard(
                            width: cardWidth,
                            title: 'Liquid Cash Reserves',
                            value: _formatCurrency(summary.totalWalletBalance),
                            subtitle: '${wallets.length} Connected Accounts',
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: AppColors.primary,
                          ),
                          _buildMetricCard(
                            width: cardWidth,
                            title: 'Goal Reserves',
                            value: _formatCurrency(summary.totalGoalSaved),
                            subtitle: '${summary.goalProgressPercentage.toStringAsFixed(1)}% Goal Completion',
                            icon: Icons.show_chart,
                            iconColor: AppColors.tertiary,
                          ),
                          _buildMetricCard(
                            width: cardWidth,
                            title: 'Monthly Outflow',
                            value: _formatCurrency(summary.totalExpenses),
                            subtitle: 'Target: ${_formatCurrency(summary.targetBudget)}',
                            icon: Icons.local_fire_department_outlined,
                            iconColor: AppColors.secondary,
                          ),
                          _buildMetricCard(
                            width: cardWidth,
                            title: 'Financial Health',
                            value: '${summary.healthScore}/100',
                            subtitle: summary.hasData ? 'Active Telemetry' : 'Awaiting Records',
                            icon: Icons.shield_outlined,
                            iconColor: AppColors.aiAccent,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Interactive Quick Actions Bar
                  Text('Command Actions', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickActionButton(
                          label: '+ Add Expense',
                          icon: Icons.add_circle_outline,
                          onPressed: () => context.go(AppRoutes.addExpense),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        _buildQuickActionButton(
                          label: 'Connect Account',
                          icon: Icons.account_balance_outlined,
                          onPressed: () => context.go(AppRoutes.connectBank),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        _buildQuickActionButton(
                          label: 'Scan Receipt',
                          icon: Icons.qr_code_scanner,
                          onPressed: () => context.go(AppRoutes.scanReceipt),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        _buildQuickActionButton(
                          label: 'AI Audit',
                          icon: Icons.auto_awesome,
                          onPressed: () => context.go(AppRoutes.aiAssistant),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 4: Trend Line & Cash Flow Chart
                  MMChartContainer(
                    title: 'Real-time Net Worth Trajectory',
                    subtitle: 'Historical growth and liquidity trend',
                    legendItems: [
                      _buildLegendItem('Net Worth', AppColors.primary),
                      const SizedBox(width: 8),
                      _buildLegendItem('Assets', AppColors.tertiary),
                    ],
                    chart: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _periods.map((p) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: MMCategoryChip(
                                  label: p,
                                  isSelected: _selectedPeriod == p,
                                  onSelected: () => setState(() => _selectedPeriod = p),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Expanded(
                          child: CommandCenterChart(period: _selectedPeriod),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: Urgent Financial Alerts Feed
                  MMSectionHeader(
                    title: 'Urgent System Alerts',
                    actionLabel: 'View All Alerts',
                    onAction: () => context.go(AppRoutes.alerts),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  if (summary.budgetUsagePercentage > 80)
                    _buildAlertCard(
                      title: 'High Monthly Budget Usage (${summary.budgetUsagePercentage.toStringAsFixed(1)}%)',
                      description: 'Total expenses of ${_formatCurrency(summary.totalExpenses)} approaching your target limit of ${_formatCurrency(summary.targetBudget)}.',
                      isCritical: true,
                      onTap: () => context.go(AppRoutes.alerts),
                    )
                  else if (wallets.isEmpty)
                    _buildAlertCard(
                      title: 'No Payment Wallet Connected',
                      description: 'Connect a bank account or UPI wallet to enable automatic tracking and balance metrics.',
                      isCritical: false,
                      onTap: () => context.go(AppRoutes.connectBank),
                    )
                  else
                    _buildAlertCard(
                      title: 'System Standing Good',
                      description: 'All wallets and spending bounds are operating within safe parameters.',
                      isCritical: false,
                      onTap: () => context.go(AppRoutes.alerts),
                    ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 6: Asset & Liability Breakdown Matrix
                  MMSectionHeader(
                    title: 'Asset & Liability Matrix',
                    actionLabel: 'Compact Net Worth',
                    onAction: () => context.go(AppRoutes.netWorthCompact),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: c,
                            isSelected: _selectedCategory == c,
                            onSelected: () => setState(() => _selectedCategory = c),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Column(
                      children: wallets.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('No accounts connected yet.', style: AppTypography.bodyMedium),
                              )
                            ]
                          : wallets.map((w) => _MatrixRow(
                                title: w.name,
                                subtitle: '${w.type} (${w.provider})',
                                amount: _formatCurrency(w.balance),
                                isPositive: true,
                              )).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 7: K2i AI Command Center Insight
                  MMAIInsightCard(
                    title: 'Command Optimization Detected',
                    description: summary.hasData
                        ? 'Net cash flow stands at ${_formatCurrency(summary.netCashFlow)}. Financial health score is ${summary.healthScore}/100.'
                        : 'No transaction telemetry recorded yet. Log an expense or connect an account to receive AI optimization advice.',
                    actionLabel: 'Consult K2i AI Engine',
                    onAction: () => context.go(AppRoutes.aiAssistant),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 8: Recent Activity Log
                  MMSectionHeader(
                    title: 'Command Activity Stream',
                    actionLabel: 'View All Transactions',
                    onAction: () => context.go(AppRoutes.transactions),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  if (recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('No recent transactions recorded.', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    )
                  else
                    ...recentTransactions.map((tx) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
                      child: MMTransactionTile(
                        title: tx.title,
                        category: tx.category,
                        amount: _formatCurrency(tx.amount),
                        timestamp: '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                        icon: tx.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                        isExpense: tx.isExpense,
                      ),
                    )),
                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.labelSmall),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String description,
    required bool isCritical,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: isCritical ? AppColors.errorContainer.withValues(alpha: 0.3) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isCritical ? AppColors.error.withValues(alpha: 0.5) : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
              color: isCritical ? AppColors.error : AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCritical ? AppColors.error : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(description, style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MatrixRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;

  const _MatrixRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 12)),
            ],
          ),
          Text(
            amount,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Net Worth Tracker (Compact) (2a0e25a4b2204d4da8443620340eeeb8)
class NetWorthCompactPage extends ConsumerStatefulWidget {
  const NetWorthCompactPage({super.key});

  @override
  ConsumerState<NetWorthCompactPage> createState() => _NetWorthCompactPageState();
}

class _NetWorthCompactPageState extends ConsumerState<NetWorthCompactPage> {
  String _selectedPeriod = '1M';
  final List<String> _periods = const ['1M', '3M', '6M', '1Y', 'YTD', 'ALL'];

  String _formatCurrency(num amount) {
    final str = amount.toInt().toString();
    final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
    final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '₹$result';
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();
    final double totalAssets = summary.totalWalletBalance + summary.totalGoalSaved;

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
          'Net Worth Tracker',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.netWorth),
            icon: const Icon(Icons.analytics_outlined, size: 18, color: AppColors.primary),
            label: Text(
              'Detailed',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  // Section 1: Compact Net Worth Summary Hero
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
                              'TOTAL NET WORTH',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            MMStatusChip(
                              label: summary.hasData ? '${summary.savingsRate.toStringAsFixed(1)}% Saved' : 'No Data',
                              backgroundColor: const Color(0xFFE6F4EA),
                              textColor: const Color(0xFF137333),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          _formatCurrency(totalAssets),
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 34,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('LIQUID ASSETS', style: AppTypography.labelSmall),
                                Text(
                                  _formatCurrency(summary.totalWalletBalance),
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: AppColors.primaryContainer,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('GOAL RESERVES', style: AppTypography.labelSmall),
                                Text(
                                  _formatCurrency(summary.totalGoalSaved),
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: AppColors.tertiary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        const MMProgressBar(progress: 0.85, height: 6),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Time Period Filter Selector Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _periods.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: p,
                            isSelected: _selectedPeriod == p,
                            onSelected: () => setState(() => _selectedPeriod = p),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Compact Net Worth Curve Chart Card
                  MMChartContainer(
                    title: 'Net Worth Trajectory',
                    subtitle: 'Compact visual trend over time',
                    chart: CompactNetWorthChart(period: _selectedPeriod),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 4: Asset & Debt Quick Breakdown List
                  MMSectionHeader(
                    title: 'Asset & Debt Breakdown',
                    actionLabel: 'Manage Wallets',
                    onAction: () => context.go(AppRoutes.wallets),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: const Column(
                      children: [
                        _AssetBreakdownTile(
                          title: 'Liquid Cash & Savings',
                          subtitle: 'Bank accounts, Cash & Deposits',
                          amount: '₹45,00,000',
                          percentage: '+2.1%',
                          chipLabel: 'Liquid',
                          chipColor: Color(0xFFE8F5E9),
                          chipTextColor: Color(0xFF2E7D32),
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _AssetBreakdownTile(
                          title: 'Investment Portfolio',
                          subtitle: 'Equities, Mutual Funds & Crypto',
                          amount: '₹85,00,000',
                          percentage: '+8.4%',
                          chipLabel: 'Growing',
                          chipColor: Color(0xFFEDE7F6),
                          chipTextColor: Color(0xFF512DA8),
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _AssetBreakdownTile(
                          title: 'Real Estate & Assets',
                          subtitle: 'Property & Physical Assets',
                          amount: '₹20,00,000',
                          percentage: '0.0%',
                          chipLabel: 'Stable',
                          chipColor: Color(0xFFFFF8E1),
                          chipTextColor: Color(0xFFF57F17),
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _AssetBreakdownTile(
                          title: 'Credit & Outstanding Loans',
                          subtitle: 'Home loan, Credit Cards',
                          amount: '-₹25,50,000',
                          percentage: '-1.2%',
                          chipLabel: 'Liability',
                          chipColor: Color(0xFFFFEBEE),
                          chipTextColor: Color(0xFFC62828),
                          isLiability: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: Key Net Worth Ratios & Metrics
                  Text('Wealth Health Highlights', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRatioCard(
                          title: 'Debt-to-Asset',
                          value: '17.0%',
                          status: 'Healthy',
                          statusColor: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: _buildRatioCard(
                          title: 'Liquidity Buffer',
                          value: '6.2x',
                          status: 'Optimal',
                          statusColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 6: Action Button to Detailed Net Worth
                  MMButton(
                    label: 'View Detailed Net Worth Tracker',
                    onPressed: () => context.go(AppRoutes.netWorth),
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

  Widget _buildRatioCard({
    required String title,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelSmall),
          const SizedBox(height: AppSpacing.s),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: AppTypography.labelSmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetBreakdownTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String percentage;
  final String chipLabel;
  final Color chipColor;
  final Color chipTextColor;
  final bool isLiability;

  const _AssetBreakdownTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.percentage,
    required this.chipLabel,
    required this.chipColor,
    required this.chipTextColor,
    this.isLiability = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MMStatusChip(
                      label: chipLabel,
                      backgroundColor: chipColor,
                      textColor: chipTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isLiability ? AppColors.error : AppColors.primary,
                ),
              ),
              Text(
                percentage,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: isLiability ? AppColors.error : const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Net Worth Tracker (Detailed) (501d98453a634c0a92d0eb85f03a5eb6)
class NetWorthDetailedPage extends ConsumerStatefulWidget {
  const NetWorthDetailedPage({super.key});

  @override
  ConsumerState<NetWorthDetailedPage> createState() => _NetWorthDetailedPageState();
}

class _NetWorthDetailedPageState extends ConsumerState<NetWorthDetailedPage> {
  String _selectedPeriod = '1Y';
  String _selectedCategory = 'All Assets';

  final List<String> _periods = const ['1M', '3M', '6M', '1Y', '3Y', 'ALL'];
  final List<String> _categories = const ['All Assets', 'Liquid', 'Investments', 'Fixed/Real Estate', 'Liabilities'];

  String _formatCurrency(num amount) {
    final str = amount.toInt().toString();
    final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
    final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '₹$result';
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();
    final wallets = ref.watch(userWalletsProvider);
    final double totalAssets = summary.totalWalletBalance + summary.totalGoalSaved;

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
          'Detailed Net Worth Tracker',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
            tooltip: 'Export Statement',
            onPressed: () => context.go(AppRoutes.reportGenerator),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
            onPressed: () {},
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
                  // Section 1: Hero Net Worth Detailed Card
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
                              'TOTAL NET WORTH VALUATION',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            MMStatusChip(
                              label: '${wallets.length} Accounts Synced',
                              backgroundColor: const Color(0xFFE8F5E9),
                              textColor: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          _formatCurrency(totalAssets),
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 38,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              summary.hasData ? '${summary.savingsRate.toStringAsFixed(1)}% Saved' : 'No Data',
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('•', style: AppTypography.labelSmall),
                            const SizedBox(width: 8),
                            Text(
                              '+18.2% YTD (+₹19,20,000)',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL ASSETS', style: AppTypography.labelSmall),
                                  Text(
                                    '₹1,50,00,000',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.primaryContainer,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
                                  Text('TOTAL LIABILITIES', style: AppTypography.labelSmall),
                                  Text(
                                    '₹25,50,000',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.error,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const MMProgressBar(progress: 0.833, height: 8),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Solvency: 83.3% Assets', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                            Text('Leverage: 16.7% Debt', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Asset Allocation Breakdown Grid
                  Text('Assets Portfolio Allocation', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 540;
                      final cardWidth = isWide ? (constraints.maxWidth - AppSpacing.stackMd) / 2 : constraints.maxWidth;

                      return Wrap(
                        spacing: AppSpacing.stackMd,
                        runSpacing: AppSpacing.stackMd,
                        children: [
                          _buildAssetAllocationCard(
                            width: cardWidth,
                            title: 'Liquid Cash & Savings',
                            amount: '₹45,00,000',
                            share: '30.0% of Assets',
                            icon: Icons.account_balance_outlined,
                            accentColor: AppColors.primary,
                            progress: 0.30,
                          ),
                          _buildAssetAllocationCard(
                            width: cardWidth,
                            title: 'Equities & Mutual Funds',
                            amount: '₹55,00,000',
                            share: '36.7% of Assets',
                            icon: Icons.trending_up_outlined,
                            accentColor: AppColors.tertiary,
                            progress: 0.367,
                          ),
                          _buildAssetAllocationCard(
                            width: cardWidth,
                            title: 'Fixed Deposits & Bonds',
                            amount: '₹30,00,000',
                            share: '20.0% of Assets',
                            icon: Icons.savings_outlined,
                            accentColor: AppColors.secondary,
                            progress: 0.20,
                          ),
                          _buildAssetAllocationCard(
                            width: cardWidth,
                            title: 'Real Estate & Gold',
                            amount: '₹20,00,000',
                            share: '13.3% of Assets',
                            icon: Icons.home_work_outlined,
                            accentColor: AppColors.aiAccent,
                            progress: 0.133,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Liabilities & Amortization Overview
                  Text('Liabilities & Loan Amortization', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: const Column(
                      children: [
                        _LiabilityRowTile(
                          title: 'HDFC Home Loan',
                          subtitle: '7.8% APR • 14.5 Yrs Remaining',
                          amount: '₹22,00,000',
                          monthlyPayment: '₹24,500/mo',
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _LiabilityRowTile(
                          title: 'HDFC Regalia Credit Card',
                          subtitle: '14.2% APR • Payoff Target 3 Mos',
                          amount: '₹3,50,000',
                          monthlyPayment: '₹12,000/mo',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 4: Historical Multi-Curve Growth Graph
                  MMChartContainer(
                    title: 'Historical Multi-Asset Trajectory',
                    subtitle: 'Comparative Net Worth vs Assets & Debt growth',
                    legendItems: [
                      _buildLegendDot('Net Worth', AppColors.primary),
                      const SizedBox(width: 8),
                      _buildLegendDot('Assets', AppColors.tertiary),
                      const SizedBox(width: 8),
                      _buildLegendDot('Debt', AppColors.error),
                    ],
                    chart: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _periods.map((p) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: MMCategoryChip(
                                  label: p,
                                  isSelected: _selectedPeriod == p,
                                  onSelected: () => setState(() => _selectedPeriod = p),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Expanded(
                          child: DetailedNetWorthChart(period: _selectedPeriod),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: All Connected Accounts Matrix
                  MMSectionHeader(
                    title: 'Connected Accounts Breakdown',
                    actionLabel: 'Add Account',
                    onAction: () => context.go(AppRoutes.connectBank),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: c,
                            isSelected: _selectedCategory == c,
                            onSelected: () => setState(() => _selectedCategory = c),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: const Column(
                      children: [
                        _AccountMatrixItem(
                          accountName: 'HDFC Priority Checking',
                          institution: 'HDFC Bank',
                          balance: '₹25,00,000',
                          typeTag: 'Checking',
                          changeText: '+1.5% MTD',
                          isNegative: false,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _AccountMatrixItem(
                          accountName: 'ICICI Savings Reserve',
                          institution: 'ICICI Bank',
                          balance: '₹20,00,000',
                          typeTag: 'Savings',
                          changeText: '+0.8% MTD',
                          isNegative: false,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _AccountMatrixItem(
                          accountName: 'Zerodha Mutual Funds',
                          institution: 'Zerodha Broking',
                          balance: '₹35,00,000',
                          typeTag: 'Equity MF',
                          changeText: '+9.2% MTD',
                          isNegative: false,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _AccountMatrixItem(
                          accountName: 'Direct US Stocks Portfolio',
                          institution: 'Vested / IndMoney',
                          balance: '₹20,00,000',
                          typeTag: 'Global Equity',
                          changeText: '+12.4% MTD',
                          isNegative: false,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _AccountMatrixItem(
                          accountName: 'HDFC Housing Mortgage',
                          institution: 'HDFC Ltd',
                          balance: '-₹22,00,000',
                          typeTag: 'Home Loan',
                          changeText: '-0.5% Principal Paid',
                          isNegative: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 6: Wealth Health Metrics & FI/RE Progress Card
                  Text('Financial Freedom (FI/RE) Target', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FINANCIAL INDEPENDENCE PROGRESS',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '49.8% Achieved',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Row(
                          children: [
                            Text(
                              '₹1,24,50,000',
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' / ₹2,50,00,000 Target',
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const MMProgressBar(progress: 0.498, height: 8),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'Estimated FI/RE Freedom Date: October 2034 (at current +₹1,15,000/mo velocity)',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 7: K2i AI Net Worth Optimization Insight Card
                  MMAIInsightCard(
                    title: 'Mortgage Prepayment Recommendation',
                    description: 'Prepaying ₹2,00,000 towards your HDFC Home Loan will save ₹4,80,000 in interest payments and reduce loan duration by 1.5 years.',
                    actionLabel: 'Run Refinance Simulation',
                    onAction: () => context.go(AppRoutes.aiAssistant),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 8: Export PDF Statement Action Button
                  MMButton(
                    label: 'Export Detailed Net Worth Report (PDF)',
                    onPressed: () => context.go(AppRoutes.reportGenerator),
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

  Widget _buildAssetAllocationCard({
    required double width,
    required String title,
    required String amount,
    required String share,
    required IconData icon,
    required Color accentColor,
    required double progress,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.labelSmall),
                Icon(icon, color: accentColor, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              amount,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(share, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
            const SizedBox(height: AppSpacing.s),
            MMProgressBar(progress: progress, height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _LiabilityRowTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String monthlyPayment;

  const _LiabilityRowTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.monthlyPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              Text(monthlyPayment, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountMatrixItem extends StatelessWidget {
  final String accountName;
  final String institution;
  final String balance;
  final String typeTag;
  final String changeText;
  final bool isNegative;

  const _AccountMatrixItem({
    required this.accountName,
    required this.institution,
    required this.balance,
    required this.typeTag,
    required this.changeText,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      accountName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MMStatusChip(
                      label: typeTag,
                      backgroundColor: isNegative ? AppColors.errorContainer : AppColors.secondaryContainer,
                      textColor: isNegative ? AppColors.onErrorContainer : AppColors.onSecondaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(institution, style: AppTypography.labelSmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? AppColors.error : AppColors.primary,
                ),
              ),
              Text(
                changeText,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: isNegative ? AppColors.error : const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Income & Cash Flow Analysis (b40e26ef5a404b92902eae7575d07d9b)
class CashFlowAnalysisPage extends ConsumerStatefulWidget {
  const CashFlowAnalysisPage({super.key});

  @override
  ConsumerState<CashFlowAnalysisPage> createState() => _CashFlowAnalysisPageState();
}

class _CashFlowAnalysisPageState extends ConsumerState<CashFlowAnalysisPage> {
  String _selectedPeriod = '1M';
  String _selectedType = 'All Flow';

  final List<String> _periods = const ['1M', '3M', '6M', '1Y', 'YTD', 'ALL'];
  final List<String> _types = const ['All Flow', 'Income Sources', 'Expenses', 'Savings Transfer'];

  @override
  Widget build(BuildContext context) {
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
          'Income & Cash Flow Analysis',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
            tooltip: 'Export Statement',
            onPressed: () => context.go(AppRoutes.reportGenerator),
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
                  // Section 1: Hero Net Cash Flow Header Card
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
                              'NET CASH FLOW THIS MONTH',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const MMStatusChip(
                              label: '+34.2% Net Margin',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '+₹85,500',
                          style: AppTypography.display.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontSize: 38,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL INFLOW', style: AppTypography.labelSmall),
                                  Text(
                                    '₹2,50,000',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: const Color(0xFF10B981),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('+12.0% vs avg', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(height: 40, width: 1, color: AppColors.outlineVariant),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL OUTFLOW', style: AppTypography.labelSmall),
                                  Text(
                                    '₹1,64,500',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.secondary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('-5.4% vs avg', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const MMProgressBar(progress: 0.658, height: 8),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Outflow: 65.8% Inflow', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                            Text('Surplus Saved: 34.2%', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Cash Flow Key Ratios Grid
                  Text('Cash Flow Performance Metrics', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 540;
                      final cardWidth = isWide ? (constraints.maxWidth - AppSpacing.stackMd) / 2 : constraints.maxWidth;

                      return Wrap(
                        spacing: AppSpacing.stackMd,
                        runSpacing: AppSpacing.stackMd,
                        children: [
                          _buildCashFlowMetricCard(
                            width: cardWidth,
                            title: 'Savings Rate',
                            value: '34.2%',
                            subtitle: 'Target: 30.0%',
                            icon: Icons.savings_outlined,
                            iconColor: const Color(0xFF2E7D32),
                          ),
                          _buildCashFlowMetricCard(
                            width: cardWidth,
                            title: 'Operating Runway',
                            value: '6.8 Mos',
                            subtitle: 'Cash buffer status: Optimal',
                            icon: Icons.timer_outlined,
                            iconColor: AppColors.primary,
                          ),
                          _buildCashFlowMetricCard(
                            width: cardWidth,
                            title: 'Fixed vs Variable',
                            value: '62% / 38%',
                            subtitle: 'Essential commitment ratio',
                            icon: Icons.pie_chart_outline,
                            iconColor: AppColors.tertiary,
                          ),
                          _buildCashFlowMetricCard(
                            width: cardWidth,
                            title: 'Daily Burn Rate',
                            value: '₹5,483',
                            subtitle: 'Average daily outflow',
                            icon: Icons.speed_outlined,
                            iconColor: AppColors.secondary,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Dual Bar & Trend Line Cash Flow Chart
                  MMChartContainer(
                    title: 'Inflow vs Outflow Historical Trend',
                    subtitle: 'Comparative monthly cash movement',
                    legendItems: [
                      _buildLegendPill('Inflow', const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _buildLegendPill('Outflow', AppColors.secondary),
                      const SizedBox(width: 8),
                      _buildLegendPill('Net Flow', AppColors.primary),
                    ],
                    chart: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _periods.map((p) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: MMCategoryChip(
                                  label: p,
                                  isSelected: _selectedPeriod == p,
                                  onSelected: () => setState(() => _selectedPeriod = p),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Expanded(
                          child: CashFlowChart(period: _selectedPeriod),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 4: Income Sources Breakdown
                  MMSectionHeader(
                    title: 'Income Sources Breakdown',
                    actionLabel: 'Add Income',
                    onAction: () => context.go(AppRoutes.addExpense),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: const Column(
                      children: [
                        _IncomeSourceTile(
                          sourceName: 'Primary Salary (TechCorp Inc)',
                          amount: '₹2,00,000',
                          shareText: '80.0% of Total Income',
                          accountTag: 'HDFC Priority',
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _IncomeSourceTile(
                          sourceName: 'Consulting & Freelance',
                          amount: '₹35,000',
                          shareText: '14.0% of Total Income',
                          accountTag: 'ICICI Direct',
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _IncomeSourceTile(
                          sourceName: 'Investment Dividends & Yield',
                          amount: '₹15,000',
                          shareText: '6.0% of Total Income',
                          accountTag: 'Zerodha Broking',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: Expense Categorization & Cash Outflow Matrix
                  MMSectionHeader(
                    title: 'Cash Outflow Allocation',
                    actionLabel: 'Spending Analysis',
                    onAction: () => context.go(AppRoutes.spendingAnalysis),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _types.map((t) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: t,
                            isSelected: _selectedType == t,
                            onSelected: () => setState(() => _selectedType = t),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: const Column(
                      children: [
                        _OutflowCategoryRow(
                          categoryName: 'Fixed Essential (Rent, EMI, Utilities)',
                          amount: '₹1,02,000',
                          percentageText: '62.0% of Outflow',
                          progress: 0.62,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _OutflowCategoryRow(
                          categoryName: 'Discretionary (Dining, Travel, Shopping)',
                          amount: '₹42,500',
                          percentageText: '25.8% of Outflow',
                          progress: 0.258,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _OutflowCategoryRow(
                          categoryName: 'Savings & Wealth Transfer (SIP)',
                          amount: '₹20,000',
                          percentageText: '12.2% of Outflow',
                          progress: 0.122,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 6: Cash Flow Forecast & 30-Day Predictor Box
                  Text('30-Day Cash Flow Forecast', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PREDICTED NEXT 30 DAYS NET SURPLUS',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const MMStatusChip(
                              label: 'High Confidence',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '+₹92,000',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.primary,
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
                                  Text('Expected Inflow', style: AppTypography.labelSmall),
                                  Text(
                                    '₹2,00,000',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: const Color(0xFF10B981),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Salary credit 1st Sep', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(height: 36, width: 1, color: AppColors.outlineVariant),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Expected Outflow', style: AppTypography.labelSmall),
                                  Text(
                                    '₹1,08,000',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Bills, Rent & SIPs', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 7: K2i AI Cash Flow Insight Card
                  MMAIInsightCard(
                    title: 'Cash Surplus Optimization Detected',
                    description: 'Your predicted net cash flow for August is ₹85,500 (+14.2% higher than average). Moving ₹35,000 surplus into high-yield liquid funds will generate ₹2,450 additional annual yield.',
                    actionLabel: 'Auto-allocate Surplus with K2i AI',
                    onAction: () => context.go(AppRoutes.aiAssistant),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 8: Recent Cash Flow Activity Log
                  MMSectionHeader(
                    title: 'Recent Cash Flow Activity',
                    actionLabel: 'View All Transactions',
                    onAction: () => context.go(AppRoutes.transactions),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  const MMTransactionTile(
                    title: 'TechCorp Salary Payment',
                    category: 'Income',
                    amount: '₹2,00,000',
                    timestamp: '01 Aug 2026',
                    icon: Icons.arrow_downward,
                    isExpense: false,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  const MMTransactionTile(
                    title: 'Apartment Rent Payment',
                    category: 'Housing & Rent',
                    amount: '₹35,000',
                    timestamp: '02 Aug 2026',
                    icon: Icons.home_outlined,
                    isExpense: true,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  const MMTransactionTile(
                    title: 'Freelance Design Payment',
                    category: 'Income',
                    amount: '₹35,000',
                    timestamp: '05 Aug 2026',
                    icon: Icons.work_outline,
                    isExpense: false,
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 9: Primary and Secondary Action CTAs
                  MMButton(
                    label: 'View Detailed Spending Analysis',
                    onPressed: () => context.go(AppRoutes.spendingAnalysis),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Export Cash Flow Statement (PDF)',
                    onPressed: () => context.go(AppRoutes.reportGenerator),
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

  Widget _buildCashFlowMetricCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.labelSmall),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendPill(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _IncomeSourceTile extends StatelessWidget {
  final String sourceName;
  final String amount;
  final String shareText;
  final String accountTag;

  const _IncomeSourceTile({
    required this.sourceName,
    required this.amount,
    required this.shareText,
    required this.accountTag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      sourceName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MMStatusChip(
                      label: accountTag,
                      backgroundColor: const Color(0xFFE8F5E9),
                      textColor: const Color(0xFF2E7D32),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(shareText, style: AppTypography.labelSmall.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutflowCategoryRow extends StatelessWidget {
  final String categoryName;
  final String amount;
  final String percentageText;
  final double progress;

  const _OutflowCategoryRow({
    required this.categoryName,
    required this.amount,
    required this.percentageText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                amount,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(percentageText, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          MMProgressBar(progress: progress, height: 4),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Detailed Spending Analysis (140797d4b2d44b70b8cb995a53b53047)
class SpendingAnalysisPage extends ConsumerStatefulWidget {
  const SpendingAnalysisPage({super.key});

  @override
  ConsumerState<SpendingAnalysisPage> createState() => _SpendingAnalysisPageState();
}

class _SpendingAnalysisPageState extends ConsumerState<SpendingAnalysisPage> {
  String _selectedPeriod = '1M';
  String _selectedFilter = 'All Categories';

  final List<String> _periods = const ['1M', '3M', '6M', '1Y', 'ALL'];
  final List<String> _filters = const ['All Categories', 'Essential', 'Discretionary', 'Recurring'];

  @override
  Widget build(BuildContext context) {
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
          'Detailed Spending Analysis',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
            tooltip: 'Export Statement',
            onPressed: () => context.go(AppRoutes.reportGenerator),
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
                  // Section 1: Hero Total Spending Card
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
                              'TOTAL SPENT THIS MONTH',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const MMStatusChip(
                              label: '-5.4% vs last month',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '₹1,64,500',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 38,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DAILY AVERAGE', style: AppTypography.labelSmall),
                                  Text(
                                    '₹5,483 / day',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.primaryContainer,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                  Text('BUDGET CEILING', style: AppTypography.labelSmall),
                                  Text(
                                    '₹1,80,000',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: AppColors.secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const MMProgressBar(progress: 0.914, height: 8),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('91.4% of budget spent', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                            Text('₹15,500 remaining', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Donut Category Distribution Chart Card
                  MMChartContainer(
                    title: 'Category Share Distribution',
                    subtitle: 'Relative spending by category',
                    legendItems: [
                      _buildLegendDot('Housing', AppColors.tertiary),
                      const SizedBox(width: 6),
                      _buildLegendDot('Food', AppColors.primary),
                      const SizedBox(width: 6),
                      _buildLegendDot('Shopping', AppColors.secondary),
                    ],
                    chart: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _periods.map((p) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: MMCategoryChip(
                                  label: p,
                                  isSelected: _selectedPeriod == p,
                                  onSelected: () => setState(() => _selectedPeriod = p),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Expanded(
                          child: SpendingAnalysisChart(period: _selectedPeriod),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Top Spending Categories Ranking Matrix
                  MMSectionHeader(
                    title: 'Top Spending Categories',
                    actionLabel: 'Manage Budgets',
                    onAction: () => context.go(AppRoutes.goals),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: f,
                            isSelected: _selectedFilter == f,
                            onSelected: () => setState(() => _selectedFilter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: const Column(
                      children: [
                        _CategoryRankingRow(
                          categoryName: 'Housing & Rent',
                          amount: '₹55,000',
                          percentageText: '33.4% • 3 transactions',
                          icon: Icons.home_outlined,
                          iconColor: AppColors.tertiary,
                          progress: 0.334,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _CategoryRankingRow(
                          categoryName: 'Food & Dining',
                          amount: '₹42,500',
                          percentageText: '25.8% • 28 transactions',
                          icon: Icons.restaurant_outlined,
                          iconColor: AppColors.primary,
                          progress: 0.258,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _CategoryRankingRow(
                          categoryName: 'Shopping & Lifestyle',
                          amount: '₹28,000',
                          percentageText: '17.0% • 12 transactions',
                          icon: Icons.shopping_bag_outlined,
                          iconColor: AppColors.secondary,
                          progress: 0.170,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _CategoryRankingRow(
                          categoryName: 'Subscriptions & Bills',
                          amount: '₹20,000',
                          percentageText: '12.2% • 6 transactions',
                          icon: Icons.subscriptions_outlined,
                          iconColor: AppColors.aiAccent,
                          progress: 0.122,
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _CategoryRankingRow(
                          categoryName: 'Travel & Commute',
                          amount: '₹19,000',
                          percentageText: '11.6% • 18 transactions',
                          icon: Icons.directions_car_outlined,
                          iconColor: Color(0xFFE57373),
                          progress: 0.116,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 4: Top Merchant Outflows
                  Text('Top Merchant Outflows', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.s),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: const Column(
                      children: [
                        _MerchantOutflowTile(
                          merchantName: 'Amazon India',
                          category: 'Shopping',
                          amount: '₹14,500',
                          txnCount: '4 Orders',
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _MerchantOutflowTile(
                          merchantName: 'Star Bazaar Groceries',
                          category: 'Food & Dining',
                          amount: '₹12,400',
                          txnCount: '6 Visits',
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _MerchantOutflowTile(
                          merchantName: 'Starbucks Coffee',
                          category: 'Food & Dining',
                          amount: '₹4,200',
                          txnCount: '8 Purchases',
                        ),
                        Divider(height: 1, color: AppColors.outlineVariant),
                        _MerchantOutflowTile(
                          merchantName: 'Uber Rides',
                          category: 'Travel & Commute',
                          amount: '₹3,800',
                          txnCount: '12 Rides',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 5: K2i AI Spending Coach Recommendation Card
                  MMAIInsightCard(
                    title: 'Food & Dining Ceiling Exceeded',
                    description: 'Food & Dining spending is 18% above your target baseline. Setting a ₹35,000 monthly ceiling will save ₹7,500/mo towards your Emergency Fund goal.',
                    actionLabel: 'Set Category Ceiling with K2i AI',
                    onAction: () => context.go(AppRoutes.goals),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 6: Recent Category Outflows List
                  MMSectionHeader(
                    title: 'Recent Spending Transactions',
                    actionLabel: 'View All Transactions',
                    onAction: () => context.go(AppRoutes.transactions),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  const MMTransactionTile(
                    title: 'Starbucks Coffee',
                    category: 'Food & Dining',
                    amount: '₹450',
                    timestamp: 'Today, 04:15 PM',
                    icon: Icons.coffee,
                    isExpense: true,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  const MMTransactionTile(
                    title: 'Amazon Electronics Purchase',
                    category: 'Shopping',
                    amount: '₹4,200',
                    timestamp: 'Yesterday, 02:30 PM',
                    icon: Icons.shopping_cart,
                    isExpense: true,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  const MMTransactionTile(
                    title: 'Uber Commute',
                    category: 'Travel',
                    amount: '₹320',
                    timestamp: '11 Aug 2026',
                    icon: Icons.directions_car,
                    isExpense: true,
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 7: Action CTAs
                  MMButton(
                    label: 'Set Category Budget Limits',
                    onPressed: () => context.go(AppRoutes.goals),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Export Spending Analysis Report (PDF)',
                    onPressed: () => context.go(AppRoutes.reportGenerator),
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

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _CategoryRankingRow extends StatelessWidget {
  final String categoryName;
  final String amount;
  final String percentageText;
  final IconData icon;
  final Color iconColor;
  final double progress;

  const _CategoryRankingRow({
    required this.categoryName,
    required this.amount,
    required this.percentageText,
    required this.icon,
    required this.iconColor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    categoryName,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(percentageText, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
          const SizedBox(height: AppSpacing.s),
          MMProgressBar(progress: progress, height: 4),
        ],
      ),
    );
  }
}

class _MerchantOutflowTile extends StatelessWidget {
  final String merchantName;
  final String category;
  final String amount;
  final String txnCount;

  const _MerchantOutflowTile({
    required this.merchantName,
    required this.category,
    required this.amount,
    required this.txnCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(merchantName, style: AppTypography.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('$category • $txnCount', style: AppTypography.labelSmall.copyWith(fontSize: 12)),
            ],
          ),
          Text(
            amount,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Financial Alerts Center (891aa3c34ba14bb2b42f1f99d8a35686)
class AlertsCenterPage extends ConsumerStatefulWidget {
  const AlertsCenterPage({super.key});

  @override
  ConsumerState<AlertsCenterPage> createState() => _AlertsCenterPageState();
}

class _AlertsCenterPageState extends ConsumerState<AlertsCenterPage> {
  String _selectedFilter = 'All Alerts';
  bool _allMarkedRead = false;

  final List<String> _filters = const ['All Alerts', 'Critical', 'Reminders', 'AI Insights', 'Resolved'];

  @override
  Widget build(BuildContext context) {
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
          'Financial Alerts Center',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.primary),
            tooltip: 'Mark All as Read',
            onPressed: () {
              setState(() => _allMarkedRead = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All alerts marked as read.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: AppColors.primary),
            onPressed: () => context.go(AppRoutes.settings),
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
                  // Section 1: Alerts Monitor Summary Header Card
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
                              'SYSTEM ALERTS MONITOR',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() => _allMarkedRead = true),
                              child: Text(
                                'Mark All Read',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          _allMarkedRead ? '0 Unread Alerts' : '6 Active Alerts',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const Row(
                          children: [
                            Expanded(
                              child: _AlertSummaryPill(
                                count: '2',
                                label: 'Critical',
                                color: AppColors.errorContainer,
                                textColor: AppColors.error,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _AlertSummaryPill(
                                count: '4',
                                label: 'Reminders',
                                color: AppColors.tertiaryFixed,
                                textColor: AppColors.onTertiaryContainer,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _AlertSummaryPill(
                                count: '3',
                                label: 'AI Insights',
                                color: AppColors.aiContainer,
                                textColor: AppColors.aiAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 2: Category Filter Chips Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: f,
                            isSelected: _selectedFilter == f,
                            onSelected: () => setState(() => _selectedFilter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Section 3: Critical Financial Warnings Section
                  if (_selectedFilter == 'All Alerts' || _selectedFilter == 'Critical') ...[
                    Text('Critical Financial Warnings', style: AppTypography.headlineMedium),
                    const SizedBox(height: AppSpacing.s),
                    FinancialAlertTile(
                      title: 'HDFC Credit Card Utilization High (82%)',
                      description: 'Current balance ₹1,23,000 out of ₹1,50,000 credit limit. Pay now to prevent credit score penalty.',
                      timestamp: '10 mins ago',
                      priority: AlertPriority.critical,
                      actionLabel: 'Pay Credit Card Bill',
                      onAction: () => context.go(AppRoutes.bills),
                      isUnread: !_allMarkedRead,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    FinancialAlertTile(
                      title: 'Emergency Cushion Deficit Warning',
                      description: 'Liquid cash reserves currently cover 2.8 months of expenses (Target: 6.0 months). Add funds to restore cushion.',
                      timestamp: '2 hours ago',
                      priority: AlertPriority.critical,
                      actionLabel: 'Deposit Cash Reserves',
                      onAction: () => context.go(AppRoutes.connectBank),
                      isUnread: !_allMarkedRead,
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Section 4: Important Reminders & Bill Deadlines Section
                  if (_selectedFilter == 'All Alerts' || _selectedFilter == 'Reminders') ...[
                    Text('Upcoming Bill & SIP Reminders', style: AppTypography.headlineMedium),
                    const SizedBox(height: AppSpacing.s),
                    FinancialAlertTile(
                      title: 'Mutual Fund SIP Renewal Due',
                      description: '₹15,000 scheduled for auto-deduction on 15th Aug from HDFC Savings Account.',
                      timestamp: '1 day ago',
                      priority: AlertPriority.warning,
                      actionLabel: 'View SIP Details',
                      onAction: () => context.go(AppRoutes.goals),
                      isUnread: !_allMarkedRead,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    FinancialAlertTile(
                      title: 'BESCOM Electricity Utility Bill Due',
                      description: '₹3,450 utility bill due on 18th Aug.',
                      timestamp: '2 days ago',
                      priority: AlertPriority.warning,
                      actionLabel: 'Pay Utility Bill',
                      onAction: () => context.go(AppRoutes.bills),
                      isUnread: !_allMarkedRead,
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Section 5: K2i AI Advisory & System Insights Section
                  if (_selectedFilter == 'All Alerts' || _selectedFilter == 'AI Insights') ...[
                    Text('K2i AI Intelligence Alerts', style: AppTypography.headlineMedium),
                    const SizedBox(height: AppSpacing.s),
                    FinancialAlertTile(
                      title: 'Digital Subscriptions Rate Increase Detected',
                      description: 'Netflix and Spotify monthly subscription fees increased by ₹250 combined. Review active subscriptions.',
                      timestamp: '3 days ago',
                      priority: AlertPriority.info,
                      actionLabel: 'Manage Subscriptions',
                      onAction: () => context.go(AppRoutes.bills),
                      isUnread: !_allMarkedRead,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    FinancialAlertTile(
                      title: 'Cash Surplus Optimization Opportunity',
                      description: '₹35,000 unallocated surplus detected in checking account. Move to high-yield liquid funds for +4.5% APY.',
                      timestamp: '4 days ago',
                      priority: AlertPriority.info,
                      actionLabel: 'Optimize Yield with K2i AI',
                      onAction: () => context.go(AppRoutes.aiAssistant),
                      isUnread: !_allMarkedRead,
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Section 6: Read & Archived Alerts Stream
                  if (_selectedFilter == 'All Alerts' || _selectedFilter == 'Resolved') ...[
                    Text('Recently Resolved Alerts', style: AppTypography.headlineMedium),
                    const SizedBox(height: AppSpacing.s),
                    const FinancialAlertTile(
                      title: 'Monthly Salary Credit Confirmed',
                      description: '₹2,50,000 successfully credited to HDFC Priority Savings.',
                      timestamp: '01 Aug 2026',
                      priority: AlertPriority.success,
                      isUnread: false,
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    const FinancialAlertTile(
                      title: 'Apartment Rent Payment Successful',
                      description: '₹35,000 rent payment completed to landlord bank account.',
                      timestamp: '02 Aug 2026',
                      priority: AlertPriority.success,
                      isUnread: false,
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                  ],

                  // Section 7: Action CTAs
                  MMButton(
                    label: 'Configure Alert Preferences',
                    onPressed: () => context.go(AppRoutes.settings),
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Return to Main Dashboard',
                    onPressed: () => context.go(AppRoutes.dashboard),
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

class _AlertSummaryPill extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final Color textColor;

  const _AlertSummaryPill({
    required this.count,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: AppTypography.headlineMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
