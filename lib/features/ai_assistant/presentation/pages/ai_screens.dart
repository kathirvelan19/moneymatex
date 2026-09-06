import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/financial_analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_ai_insight_card.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_card.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_empty_state.dart';
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../../core/widgets/mm_section_header.dart';
import '../../../../core/widgets/mm_transaction_tile.dart';
import '../../../auth_onboarding/presentation/providers/user_profile_provider.dart';
import '../../../budgets_savings/presentation/providers/goals_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../widgets/k2i_chatbot_widget.dart';

String _formatRupees(num amount) {
  final str = amount.toInt().toString();
  final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$result';
}

Widget _buildBaseAppBar(BuildContext context, String title) {
  return AppBar(
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
      title,
      style: AppTypography.headlineMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
        onPressed: () => context.go(AppRoutes.aiChat),
      ),
      const SizedBox(width: AppSpacing.s),
    ],
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: AppColors.outlineVariant),
    ),
  );
}

/// Stitch Screen: MoneyMateX K2i AI Assistant (View A) (124a564290fe4a03b13db2feb7a9bb38)
class K2iAssistantPage extends ConsumerWidget {
  const K2iAssistantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'K2i Financial Intelligence'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'K2i Intelligence Engine',
                          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      summary.hasData
                          ? 'Hello ${profile.name.isNotEmpty ? profile.name : 'User'}, I have analyzed your transactions and account balances. Your current Financial Health Score is ${summary.healthScore}/100.'
                          : 'Welcome to K2i. Add transactions, budgets, or goals to generate personalized AI financial insights.',
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    MMPrimaryButton(
                      label: 'Start AI Conversation',
                      onPressed: () => context.go(AppRoutes.aiChat),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              MMSectionHeader(
                title: 'Quick AI Actions',
                actionLabel: 'Advisor Home',
                onAction: () => context.go(AppRoutes.aiAdvisor),
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  MMCategoryChip(
                    label: 'Health Check',
                    isSelected: false,
                    onSelected: () => context.go(AppRoutes.aiHealthScore),
                  ),
                  MMCategoryChip(
                    label: 'Cash Flow Forecast',
                    isSelected: false,
                    onSelected: () => context.go(AppRoutes.aiCashFlowForecast),
                  ),
                  MMCategoryChip(
                    label: 'Savings Optimizer',
                    isSelected: false,
                    onSelected: () => context.go(AppRoutes.aiSavingsOptimizer),
                  ),
                  MMCategoryChip(
                    label: 'Subscription Manager',
                    isSelected: false,
                    onSelected: () => context.go(AppRoutes.aiSubscriptionManager),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX K2i AI Assistant (View B) (f91f7b16770d4994a1444278e9c3a22d)
class K2iAssistantCompactPage extends ConsumerWidget {
  const K2iAssistantCompactPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'K2i Insights'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MMAIInsightCard(
                title: 'K2i Smart Analysis',
                description: summary.hasData
                    ? 'Total income is ${_formatRupees(summary.totalIncome)} with total expenses of ${_formatRupees(summary.totalExpenses)}. Net cash flow stands at ${_formatRupees(summary.netCashFlow)}.'
                    : 'No financial activity recorded yet. Connect a bank account or log expenses to receive real-time AI guidance.',
                actionLabel: 'Ask K2i AI',
                onAction: () => context.go(AppRoutes.aiChat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Advisor Home (38b5afb665e84ac6b96888ed5d40bbfc)
class AIAdvisorHomePage extends ConsumerWidget {
  const AIAdvisorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'AI Financial Advisor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Advisor Overview', style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.s),
              MMCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Financial Health', style: AppTypography.headlineMedium),
                        MMStatusChip(
                          label: '${summary.healthScore}/100',
                          backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.15),
                          textColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    MMProgressBar(progress: (summary.healthScore / 100).clamp(0.0, 1.0)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              MMSectionHeader(
                title: 'Advisor Recommendations',
                actionLabel: 'View All',
                onAction: () => context.go(AppRoutes.aiRecommendations),
              ),
              const SizedBox(height: AppSpacing.s),
              MMAIInsightCard(
                title: 'Monthly Cash Flow Target',
                description: summary.netCashFlow >= 0
                    ? 'Positive cash flow surplus of ${_formatRupees(summary.netCashFlow)}. Consider allocating surplus to active savings goals.'
                    : 'Expenses exceed income by ${_formatRupees(summary.netCashFlow.abs())}. Review top expense categories to balance budget.',
                actionLabel: 'Optimize Budget',
                onAction: () => context.go(AppRoutes.aiBudgetOptimizer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Advisor Chat (697f99717f164fa882d53ed4ef537263)
class AIAdvisorChatPage extends ConsumerWidget {
  const AIAdvisorChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'K2i AI Chat Assistant'),
      ),
      body: const SafeArea(
        child: K2iChatbotWidget(),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Financial Health Score Summary (a3b6be15fa9c476286ddfd0a27537c92)
class AIHealthScoreSummaryPage extends ConsumerWidget {
  const AIHealthScoreSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'Health Score Summary'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MMCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Score Breakdown', style: AppTypography.headlineMedium),
                    const SizedBox(height: AppSpacing.m),
                    Text('${summary.healthScore} / 100', style: AppTypography.display.copyWith(color: AppColors.primary)),
                    const SizedBox(height: AppSpacing.s),
                    MMProgressBar(progress: (summary.healthScore / 100).clamp(0.0, 1.0)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              MMSectionHeader(
                title: 'Action Plan',
                actionLabel: 'View Plan',
                onAction: () => context.go(AppRoutes.aiHealthActionPlan),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Financial Health Action Plan (6767cb3ed87f415191d30e79af6a3acc)
class AIHealthActionPlanPage extends ConsumerWidget {
  const AIHealthActionPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'Health Action Plan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recommended Actions', style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.s),
              if (!summary.hasData)
                const MMEmptyState(
                  title: 'No Action Plan Yet',
                  subtitle: 'Add transactions or savings goals to get personalized action items.',
                  icon: Icons.assignment_late_outlined,
                )
              else ...[
                _buildActionItem('Maintain savings rate above 20%', 'Current rate: ${summary.savingsRate.toStringAsFixed(1)}%'),
                _buildActionItem('Keep monthly spending within target budget', 'Current budget usage: ${summary.budgetUsagePercentage.toStringAsFixed(1)}%'),
                _buildActionItem('Contribute to active saving goals', 'Goal progress: ${summary.goalProgressPercentage.toStringAsFixed(1)}%'),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Financial Action Plan (71ff9933d1bb4e48817a265fa111b69e)
class AIActionPlanPage extends ConsumerWidget {
  const AIActionPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIHealthActionPlanPage();
  }
}

/// Stitch Screen: MoneyMateX AI Financial Health Check (56a45fe1d5f24734aebf6f65418fc504)
class AIHealthCheckPage extends ConsumerWidget {
  const AIHealthCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'AI Financial Health Check'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MMAIInsightCard(
                title: 'System Diagnostic Complete',
                description: summary.hasData
                    ? 'Health score is ${summary.healthScore}/100. Category breakdown and cash flow are active.'
                    : 'System active. Add transactions to generate dynamic diagnostic telemetry.',
                actionLabel: 'Full Score Analysis',
                onAction: () => context.go(AppRoutes.aiHealthScore),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Advisor Goal Planning (e7ade8b9e52a4878abee80c39e339018)
class AIGoalPlanningPage extends ConsumerWidget {
  const AIGoalPlanningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'AI Goal Strategy'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (goals.isEmpty)
                const MMEmptyState(
                  title: 'No Active Goals',
                  subtitle: 'Create a savings goal to activate AI Goal Strategy.',
                  icon: Icons.flag_outlined,
                )
              else
                ...goals.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MMCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name, style: AppTypography.headlineMedium),
                        const SizedBox(height: 4),
                        Text('Saved: ${_formatRupees(g.savedAmount)} of ${_formatRupees(g.targetAmount)}'),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Financial Goal Planner (View A) (bcf3e6f033e241f6906aff8844fd9659)
class AIGoalPlannerPage extends ConsumerWidget {
  const AIGoalPlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIGoalPlanningPage();
  }
}

/// Stitch Screen: MoneyMateX AI Financial Goal Planner (View B) (778a3d4b94e1499daaad318d000a67de)
class AIGoalPlannerExtendedPage extends ConsumerWidget {
  const AIGoalPlannerExtendedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIGoalPlanningPage();
  }
}

/// Stitch Screen: MoneyMateX AI Goal Planner (49b960aa0e6a4334b4f41ce03b06b000)
class AIGoalPlannerSimplePage extends ConsumerWidget {
  const AIGoalPlannerSimplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIGoalPlanningPage();
  }
}

/// Stitch Screen: MoneyMateX AI Goal Progress Tracker (c56e164c88f8427fa300993e0c788018)
class AIGoalProgressPage extends ConsumerWidget {
  const AIGoalProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'Goal Progress Intelligence'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MMCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Goal Saved', style: AppTypography.labelSmall),
                    Text(_formatRupees(summary.totalGoalSaved), style: AppTypography.display.copyWith(color: AppColors.primary)),
                    const SizedBox(height: AppSpacing.s),
                    Text('Portfolio Goal Target: ${_formatRupees(summary.totalGoalTarget)}'),
                    const SizedBox(height: AppSpacing.m),
                    MMProgressBar(progress: (summary.goalProgressPercentage / 100).clamp(0.0, 1.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Goal Optimizer (17a8737eb6834b79bd9ec9fe05c01d7b)
class AIGoalOptimizerPage extends ConsumerWidget {
  const AIGoalOptimizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIGoalProgressPage();
  }
}

/// Stitch Screen: MoneyMateX AI Goal Recovery Planner (52d578e5d0214389a35deaafc0fe0aa9)
class AIGoalRecoveryPage extends ConsumerWidget {
  const AIGoalRecoveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIGoalProgressPage();
  }
}

/// Stitch Screen: MoneyMateX AI Savings Optimizer (dd2c9a68be2a4608ab99c3a32f7e2e29)
class AISavingsOptimizerPage extends ConsumerWidget {
  const AISavingsOptimizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'AI Savings Optimizer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MMAIInsightCard(
                title: 'Savings Rate Optimization',
                description: summary.hasData
                    ? 'Current savings rate is ${summary.savingsRate.toStringAsFixed(1)}%. Net surplus is ${_formatRupees(summary.netCashFlow)}.'
                    : 'Record your monthly income and expenses to generate savings optimization recommendations.',
                actionLabel: 'View Detailed Reports',
                onAction: () => context.go(AppRoutes.reports),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Spending Coach (f477166b87a840e4affca69f3712c357)
class AISpendingCoachPage extends ConsumerWidget {
  const AISpendingCoachPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'AI Spending Coach'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MMCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Monthly Burn', style: AppTypography.labelSmall),
                    Text(_formatRupees(summary.totalExpenses), style: AppTypography.display.copyWith(color: AppColors.error)),
                    const SizedBox(height: AppSpacing.s),
                    Text('Target Budget: ${_formatRupees(summary.targetBudget)}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Spending Control (a626a949a4b24c5d9bd00b784a95815f)
class AISpendingControlPage extends ConsumerWidget {
  const AISpendingControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AISpendingCoachPage();
  }
}

/// Stitch Screen: MoneyMateX AI Budget Optimizer (e1a96b8d3caa401cb47b4bf023e3ec20)
class AIBudgetOptimizerPage extends ConsumerWidget {
  const AIBudgetOptimizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AISpendingCoachPage();
  }
}

/// Stitch Screen: MoneyMateX AI Cash Flow Predictor (9495441aad124983be27c9982864ba3e)
class AICashFlowPredictorPage extends ConsumerWidget {
  const AICashFlowPredictorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'Cash Flow Predictor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MMCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Net Monthly Flow', style: AppTypography.labelSmall),
                    Text(
                      _formatRupees(summary.netCashFlow),
                      style: AppTypography.display.copyWith(
                        color: summary.netCashFlow >= 0 ? const Color(0xFF2E7D32) : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Cash Flow Forecast (1629ee1608ae4ea79642bcdcdb8baea3)
class AICashFlowForecastPage extends ConsumerWidget {
  const AICashFlowForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AICashFlowPredictorPage();
  }
}

/// Stitch Screen: MoneyMateX AI Expense Predictor (e9301a07c5c74e7489b94c3a8536944a)
class AIExpensePredictorPage extends ConsumerWidget {
  const AIExpensePredictorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AICashFlowPredictorPage();
  }
}

/// Stitch Screen: MoneyMateX AI Subscription Manager (42d8ceefd5ec42f2b99096dc929aa0b7)
class AISubscriptionManagerPage extends ConsumerWidget {
  const AISubscriptionManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final bills = transactions.where((t) => t.isExpense && (t.category.toLowerCase().contains('bill') || t.category.toLowerCase().contains('sub'))).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'Subscription Manager'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bills.isEmpty)
                const MMEmptyState(
                  title: 'No Subscriptions Found',
                  subtitle: 'No recurring bills or subscriptions detected in your transactions.',
                  icon: Icons.subscriptions_outlined,
                )
              else
                ...bills.map((b) => MMTransactionTile(
                  title: b.title,
                  category: b.category,
                  amount: _formatRupees(b.amount),
                  timestamp: '${b.date.day}/${b.date.month}/${b.date.year}',
                  icon: Icons.subscriptions,
                  isExpense: true,
                )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Subscription Manager Detailed (3a757c34c7874f819de63f46e77dcb35)
class AISubscriptionManagerDetailedPage extends ConsumerWidget {
  const AISubscriptionManagerDetailedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AISubscriptionManagerPage();
  }
}

/// Stitch Screen: MoneyMateX AI Bill & Subscription Manager (04c179bbd3ad4f82a05b36fb7449e835)
class AIBillSubscriptionManagerPage extends ConsumerWidget {
  const AIBillSubscriptionManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AISubscriptionManagerPage();
  }
}

/// Stitch Screen: MoneyMateX AI Bill Renewal Optimizer (79da268687d14d66b0c6c01d22b98922)
class AIBillRenewalOptimizerPage extends ConsumerWidget {
  const AIBillRenewalOptimizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AISubscriptionManagerPage();
  }
}

/// Stitch Screen: MoneyMateX AI Bill Payment Optimizer (24d8121bbeac4fcc8efa58ef25b9d2d9)
class AIBillPaymentOptimizerPage extends ConsumerWidget {
  const AIBillPaymentOptimizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AISubscriptionManagerPage();
  }
}

/// Stitch Screen: MoneyMateX AI Financial Insights (421a0abea4d44948a310b0047e134abd)
class AIFinancialInsightsPage extends ConsumerWidget {
  const AIFinancialInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialAnalyticsProvider).computeSummary();
    final asyncInsights = ref.watch(spendingInsightsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _buildBaseAppBar(context, 'Financial Insights Feed'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MMAIInsightCard(
                title: 'Portfolio Health',
                description: summary.hasData
                    ? 'Your current score is ${summary.healthScore}/100 with total logged income of ${_formatRupees(summary.totalIncome)}.'
                    : 'No financial records available yet to generate insights.',
                actionLabel: 'Run Health Check',
                onAction: () => context.go(AppRoutes.aiHealthCheck),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Gemini AI Spending Insights',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              asyncInsights.when(
                data: (insights) {
                  if (insights.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppRadius.l),
                      ),
                      child: Text(
                        'No spending patterns identified yet. Log more expenses to unlock Gemini AI insights.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    );
                  }
                  return Column(
                    children: insights.map((insight) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.m),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFF7E22CE), size: 20),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: Text(
                                  insight,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFF581C87),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.l),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, stack) => Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.l),
                  ),
                  child: Text(
                    'Unable to load Gemini AI insights.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onTertiaryContainer),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX AI Financial Planning (84213091b9ce48ea8fcdd77de2412e87)
class AIFinancialPlanningPage extends ConsumerWidget {
  const AIFinancialPlanningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIFinancialInsightsPage();
  }
}

/// Stitch Screen: MoneyMateX AI Monthly Review (e84e9dbd20b3452a92d4e92be951219e)
class AIMonthlyReviewPage extends ConsumerWidget {
  const AIMonthlyReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIFinancialInsightsPage();
  }
}

/// Stitch Screen: MoneyMateX AI Personalized Plan (854a68b4e5724832b75dbfc854f81f4d)
class AIPersonalizedPlanPage extends ConsumerWidget {
  const AIPersonalizedPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIFinancialInsightsPage();
  }
}

/// Stitch Screen: MoneyMateX Personalized Financial Recommendations (631f79436c474521b9ba1c4f2e5b11a6)
class AIRecommendationsPage extends ConsumerWidget {
  const AIRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AIFinancialInsightsPage();
  }
}
