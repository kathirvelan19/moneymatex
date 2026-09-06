import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/goals_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_ai_insight_card.dart';
import '../../../../core/widgets/mm_app_bar.dart';
import '../../../../core/widgets/mm_bottom_sheet.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_card.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_empty_state.dart';
import '../../../../core/widgets/mm_progress_bar.dart';
import '../../../../core/widgets/mm_section_header.dart';
import '../../../auth_onboarding/presentation/providers/user_profile_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../widgets/mm_savings_goal_card.dart';

String _formatRupees(num amount) {
  final str = amount.toStringAsFixed(0);
  final reg = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  final result = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  return '₹$result';
}

IconData _getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'tech':
    case 'electronics':
      return Icons.phone_iphone_outlined;
    case 'travel':
    case 'vacation':
      return Icons.flight_takeoff_outlined;
    case 'security':
    case 'emergency':
      return Icons.shield_outlined;
    case 'lifestyle':
    case 'vehicle':
      return Icons.two_wheeler_outlined;
    case 'housing':
    case 'rent':
      return Icons.home_outlined;
    default:
      return Icons.savings_outlined;
  }
}

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'tech':
      return AppColors.tertiary;
    case 'travel':
      return const Color(0xFFE91E63);
    case 'security':
    case 'emergency':
      return AppColors.primary;
    case 'lifestyle':
    case 'vehicle':
      return const Color(0xFF009688);
    case 'housing':
      return AppColors.secondary;
    default:
      return AppColors.primary;
  }
}

enum ScreenState { normal, empty, loading, error }

/// ============================================================================
/// PAGE 1 — SAVINGS GOALS (Stitch Screen #36 / #37 / #38)
/// Entry Point: Goals Tab in Primary Bottom Navbar
/// ============================================================================
class SavingGoalsOverviewPage extends ConsumerStatefulWidget {
  const SavingGoalsOverviewPage({super.key});

  @override
  ConsumerState<SavingGoalsOverviewPage> createState() => _SavingGoalsOverviewPageState();
}

class _SavingGoalsOverviewPageState extends ConsumerState<SavingGoalsOverviewPage> {
  String _selectedFilter = 'All';

  void _showContributionSheet(GoalItem goal) {
    final controller = TextEditingController(text: '5000');
    final noteController = TextEditingController();

    MMBottomSheet.show(
      context: context,
      title: 'Contribute to ${goal.name}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Target: ${_formatRupees(goal.targetAmount)} • Currently Saved: ${_formatRupees(goal.savedAmount)}',
              style: AppTypography.labelSmall,
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Contribution Amount (₹)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            MMPrimaryButton(
              label: 'Confirm Contribution',
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0;
                if (amount > 0) {
                  ref.read(goalsProvider.notifier).addContribution(
                        goal.id,
                        amount,
                        note: noteController.text.trim(),
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${_formatRupees(amount)} to ${goal.name}!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);

    final totalSaved = goals.fold<double>(0.0, (sum, item) => sum + item.savedAmount);
    final totalTarget = goals.fold<double>(0.0, (sum, item) => sum + item.targetAmount);
    final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
    final activeCount = goals.where((g) => g.status != 'Completed').length;
    final completedCount = goals.where((g) => g.status == 'Completed').length;

    List<GoalItem> filteredGoals;
    switch (_selectedFilter) {
      case 'In Progress':
        filteredGoals = goals.where((g) => g.status != 'Completed').toList();
        break;
      case 'Completed':
        filteredGoals = goals.where((g) => g.status == 'Completed').toList();
        break;
      case 'High Priority':
        filteredGoals = goals.where((g) => g.priority.toLowerCase() == 'high').toList();
        break;
      default:
        filteredGoals = goals;
    }

    Widget bodyContent;

    if (goals.isEmpty) {
      bodyContent = MMEmptyState(
        icon: Icons.savings_outlined,
        title: 'No Saving Goals Found',
        subtitle: 'Start building your financial future by creating your first saving goal.',
        actionLabel: '+ Create First Goal',
        onAction: () => context.go(AppRoutes.smartPlanner),
      );
    } else if (filteredGoals.isEmpty) {
      bodyContent = Column(
        children: [
          _buildFilterChips(goals.length, activeCount, completedCount),
          const SizedBox(height: AppSpacing.l),
          MMEmptyState(
            icon: Icons.filter_alt_off_outlined,
            title: 'No Goals in "$_selectedFilter"',
            subtitle: 'Try selecting a different filter option or create a new goal.',
            actionLabel: '+ Create Goal',
            onAction: () => context.go(AppRoutes.smartPlanner),
          ),
        ],
      );
    } else {
      bodyContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Savings Summary Header Card
          MMCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Goals Portfolio', style: AppTypography.tagline),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${(overallProgress * 100).toStringAsFixed(1)}% Saved',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onPrimaryFixedVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatRupees(totalSaved),
                  style: AppTypography.display.copyWith(fontSize: 32),
                ),
                Text(
                  'Target: ${_formatRupees(totalTarget)}',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: AppSpacing.m),
                MMProgressBar(
                  progress: overallProgress,
                  height: 10,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '$activeCount Active Goals',
                          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: AppColors.tertiary),
                        const SizedBox(width: 4),
                        Text(
                          '$completedCount Completed',
                          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),

          // AI Insight Card
          MMAIInsightCard(
            title: 'MoneyMateX Goal Insights',
            description: activeCount > 0
                ? 'You have $activeCount active savings goals with a cumulative portfolio target of ${_formatRupees(totalTarget)}. Maintain monthly deposits to stay on schedule!'
                : 'Great job! All your savings targets are fully completed.',
            actionLabel: 'Smart Goal Planner →',
            onAction: () => context.go(AppRoutes.smartPlanner),
          ),
          const SizedBox(height: AppSpacing.m),

          // Filter Chips
          _buildFilterChips(goals.length, activeCount, completedCount),
          const SizedBox(height: AppSpacing.m),

          // Section Header
          MMSectionHeader(
            title: 'Your Saving Goals',
            subtitle: '${filteredGoals.length} goals displayed',
            actionLabel: '+ New Goal',
            onAction: () => context.go(AppRoutes.smartPlanner),
          ),
          const SizedBox(height: AppSpacing.s),

          // Goal cards list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredGoals.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
            itemBuilder: (context, index) {
              final goal = filteredGoals[index];
              final monthlyReq = goal.remainingAmount > 0 ? goal.remainingAmount / 10 : 0.0;
              return MMSavingsGoalCard(
                title: goal.name,
                category: goal.category,
                savedAmount: goal.savedAmount,
                targetAmount: goal.targetAmount,
                targetDate: goal.targetDate,
                status: goal.status,
                icon: _getCategoryIcon(goal.category),
                categoryColor: _getCategoryColor(goal.category),
                monthlyContribution: monthlyReq,
                isDetailedView: true,
                onTap: () => context.go(AppRoutes.goalDetails.replaceAll(':id', goal.id)),
                onContribute: () => _showContributionSheet(goal),
              );
            },
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: MMAppBar(
        title: 'Savings Goals',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Detailed Analytics',
            onPressed: () => context.go(AppRoutes.goalsDetailed),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'New Goal Planner',
            onPressed: () => context.go(AppRoutes.smartPlanner),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: bodyContent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(int total, int active, int completed) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          MMCategoryChip(
            label: 'All Goals ($total)',
            isSelected: _selectedFilter == 'All',
            onSelected: () => setState(() => _selectedFilter = 'All'),
          ),
          const SizedBox(width: AppSpacing.s),
          MMCategoryChip(
            label: 'In Progress ($active)',
            isSelected: _selectedFilter == 'In Progress',
            onSelected: () => setState(() => _selectedFilter = 'In Progress'),
          ),
          const SizedBox(width: AppSpacing.s),
          MMCategoryChip(
            label: 'Completed ($completed)',
            isSelected: _selectedFilter == 'Completed',
            onSelected: () => setState(() => _selectedFilter = 'Completed'),
          ),
          const SizedBox(width: AppSpacing.s),
          MMCategoryChip(
            label: 'High Priority',
            isSelected: _selectedFilter == 'High Priority',
            onSelected: () => setState(() => _selectedFilter = 'High Priority'),
          ),
        ],
      ),
    );
  }
}

/// Detailed View B for Goals Overview
class SavingGoalsDetailedPage extends ConsumerWidget {
  const SavingGoalsDetailedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SavingGoalsOverviewPage();
  }
}

/// Summary View C for Goals Overview
class SavingGoalsSummaryPage extends ConsumerWidget {
  const SavingGoalsSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SavingGoalsOverviewPage();
  }
}

/// ============================================================================
/// PAGE 2 — SMART GOAL PLANNER (Stitch Screen #39 / Smart Goal Planner)
/// Navigation: Savings Goals → Smart Goal Planner
/// ============================================================================
class SmartGoalPlannerPage extends ConsumerStatefulWidget {
  final GoalItem? goalToEdit;
  const SmartGoalPlannerPage({super.key, this.goalToEdit});

  @override
  ConsumerState<SmartGoalPlannerPage> createState() => _SmartGoalPlannerPageState();
}

class _SmartGoalPlannerPageState extends ConsumerState<SmartGoalPlannerPage> {
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _savedController;
  late TextEditingController _dateController;
  late TextEditingController _notesController;

  String _selectedCategory = 'Tech';
  String _selectedPriority = 'Medium';

  final List<String> _categories = const [
    'Tech',
    'Travel',
    'Security',
    'Lifestyle',
    'Vehicle',
    'Housing',
    'Education',
    'General',
  ];

  final List<String> _priorities = const ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goalToEdit?.name ?? '');
    _targetController = TextEditingController(
        text: widget.goalToEdit != null ? widget.goalToEdit!.targetAmount.toStringAsFixed(0) : '');
    _savedController = TextEditingController(
        text: widget.goalToEdit != null ? widget.goalToEdit!.savedAmount.toStringAsFixed(0) : '0');
    _dateController = TextEditingController(text: widget.goalToEdit?.targetDate ?? '');
    _notesController = TextEditingController(text: widget.goalToEdit?.notes ?? '');

    if (widget.goalToEdit != null) {
      _selectedCategory = widget.goalToEdit!.category;
      _selectedPriority = widget.goalToEdit!.priority;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onApplyPlan() {
    final name = _nameController.text.trim();
    final target = double.tryParse(_targetController.text.replaceAll(',', '')) ?? 0.0;
    final saved = double.tryParse(_savedController.text.replaceAll(',', '')) ?? 0.0;
    final dateStr = _dateController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal name is required.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target amount must be greater than 0.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (dateStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target date is required.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newGoal = GoalItem(
      id: widget.goalToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      targetAmount: target,
      savedAmount: saved,
      targetDate: dateStr,
      category: _selectedCategory,
      priority: _selectedPriority,
      createdAt: widget.goalToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      status: saved >= target ? 'Completed' : 'In Progress',
      notes: _notesController.text.trim(),
      contributions: widget.goalToEdit?.contributions ?? [],
    );

    if (widget.goalToEdit != null) {
      ref.read(goalsProvider.notifier).updateGoal(newGoal);
    } else {
      ref.read(goalsProvider.notifier).addGoal(newGoal);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "$name" saved successfully!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go(AppRoutes.goals);
  }

  @override
  Widget build(BuildContext context) {
    final target = double.tryParse(_targetController.text.replaceAll(',', '')) ?? 0.0;
    final saved = double.tryParse(_savedController.text.replaceAll(',', '')) ?? 0.0;
    final remaining = (target - saved).clamp(0.0, double.infinity);

    int monthsRemaining = 10;
    final parsedDate = DateTime.tryParse(_dateController.text.trim());
    if (parsedDate != null) {
      final now = DateTime.now();
      final diff = (parsedDate.year - now.year) * 12 + (parsedDate.month - now.month);
      monthsRemaining = diff > 0 ? diff : 1;
    }

    final recommendedMonthly = remaining > 0 ? (remaining / monthsRemaining) : 0.0;

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
              context.go(AppRoutes.goals);
            }
          },
        ),
        title: Text(
          widget.goalToEdit != null ? 'Edit Saving Goal' : 'Smart Goal Planner',
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
                  Text(
                    'Calculate & Plan Goal Strategy',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adjust target parameters below to dynamically calculate your monthly saving plan.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Calculated Recommendation Box
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
                        Text('RECOMMENDED MONTHLY SAVING', style: AppTypography.labelSmall),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatRupees(recommendedMonthly)} / month',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Remaining target of ${_formatRupees(remaining)} split across estimated timeframe ($monthsRemaining months).',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Inputs Form
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
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Goal Name *',
                            hintText: 'e.g. Laptop, Emergency Fund',
                            prefixIcon: Icon(Icons.stars_outlined),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextField(
                          controller: _targetController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Target Amount (₹) *',
                            hintText: 'e.g. 60000',
                            prefixIcon: Icon(Icons.currency_rupee),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextField(
                          controller: _savedController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Current Saved Amount (₹)',
                            hintText: 'e.g. 10000',
                            prefixIcon: Icon(Icons.savings_outlined),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Target Date *',
                            hintText: 'e.g. 2026-12-31 or Dec 2026',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.m),

                        // Priority Selector
                        Text('Priority Level', style: AppTypography.labelSmall),
                        const SizedBox(height: 6),
                        Row(
                          children: _priorities.map((p) {
                            final isSelected = _selectedPriority == p;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(p),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) setState(() => _selectedPriority = p);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        TextField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Add any specific notes or target details...',
                            prefixIcon: Icon(Icons.note_alt_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: 'Apply My Plan & Save Goal',
                    onPressed: _onApplyPlan,
                    type: MMButtonType.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  MMButton(
                    label: 'Cancel',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.goals);
                      }
                    },
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

/// ============================================================================
/// PAGE 3 — GOAL DETAILS (Stitch Screen #39 Goal Details)
/// Navigation: Savings Goals → Select Goal → Goal Details
/// ============================================================================
class SavingGoalDetailsPage extends ConsumerStatefulWidget {
  final String id;
  const SavingGoalDetailsPage({super.key, required this.id});

  @override
  ConsumerState<SavingGoalDetailsPage> createState() => _SavingGoalDetailsPageState();
}

class _SavingGoalDetailsPageState extends ConsumerState<SavingGoalDetailsPage> {
  void _showContributionSheet(GoalItem goal) {
    final controller = TextEditingController(text: '5000');
    final noteController = TextEditingController();

    MMBottomSheet.show(
      context: context,
      title: 'Add Contribution to ${goal.name}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Saved: ${_formatRupees(goal.savedAmount)} / Target: ${_formatRupees(goal.targetAmount)}',
              style: AppTypography.labelSmall,
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Contribution Amount (₹)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            MMPrimaryButton(
              label: 'Confirm Contribution',
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0;
                if (amount > 0) {
                  ref.read(goalsProvider.notifier).addContribution(
                        goal.id,
                        amount,
                        note: noteController.text.trim(),
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deposited ${_formatRupees(amount)} to ${goal.name}!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteGoal(GoalItem goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${goal.name}"?'),
        content: const Text(
          'Are you sure you want to delete this saving goal? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(goalsProvider.notifier).deleteGoal(goal.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Goal "${goal.name}" deleted.')),
              );
              context.go(AppRoutes.goals);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);

    final GoalItem? goal = goals.where((g) => g.id == widget.id).firstOrNull;

    if (goal == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: const MMAppBar(
          title: 'Goal Details',
          showBackButton: true,
        ),
        body: SafeArea(
          child: Center(
            child: MMEmptyState(
              icon: Icons.search_off_outlined,
              title: 'Goal Not Found',
              subtitle: 'No saving goal data matches the requested identifier.',
              actionLabel: 'Return to Savings Goals',
              onAction: () => context.go(AppRoutes.goals),
            ),
          ),
        ),
      );
    }

    final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);
    final remainingAmount = (goal.targetAmount - goal.savedAmount).clamp(0.0, double.infinity);
    final requiredMonthly = remainingAmount > 0 ? remainingAmount / 10 : 0.0;

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
              context.go(AppRoutes.goals);
            }
          },
        ),
        title: Text(
          goal.name,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: 'Edit Goal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SmartGoalPlannerPage(goalToEdit: goal),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Goal',
            onPressed: () => _confirmDeleteGoal(goal),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Goal Card Banner
                  MMCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(goal.category).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.l),
                              ),
                              child: Icon(
                                _getCategoryIcon(goal.category),
                                color: _getCategoryColor(goal.category),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          goal.name,
                                          style: AppTypography.headlineMedium.copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      MMStatusChip(
                                        label: goal.status,
                                        backgroundColor: goal.status == 'Completed'
                                            ? AppColors.tertiaryFixed
                                            : AppColors.primaryFixed,
                                        textColor: goal.status == 'Completed'
                                            ? AppColors.onTertiaryContainer
                                            : AppColors.onPrimaryFixedVariant,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${goal.category} • Target Date: ${goal.targetDate} • Priority: ${goal.priority}',
                                    style: AppTypography.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.l),

                        // Amount Figures
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CURRENT SAVINGS', style: AppTypography.tagline),
                                Text(
                                  _formatRupees(goal.savedAmount),
                                  style: AppTypography.display.copyWith(
                                    fontSize: 32,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('TARGET ($percentage%)', style: AppTypography.tagline),
                                Text(
                                  _formatRupees(goal.targetAmount),
                                  style: AppTypography.headlineMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),

                        // Progress Bar
                        MMProgressBar(
                          progress: progress,
                          height: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.m),

                        // Quick Specs Grid
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text('Remaining', style: AppTypography.labelSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatRupees(remainingAmount),
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 24, color: AppColors.outlineVariant),
                              Column(
                                children: [
                                  Text('Required Monthly', style: AppTypography.labelSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_formatRupees(requiredMonthly)}/mo',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 24, color: AppColors.outlineVariant),
                              Column(
                                children: [
                                  Text('Category', style: AppTypography.labelSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    goal.category,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: MMPrimaryButton(
                          label: '+ Add Contribution',
                          icon: Icons.add_circle_outline,
                          onPressed: () => _showContributionSheet(goal),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: MMSecondaryButton(
                          label: 'Edit Goal',
                          icon: Icons.edit_outlined,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SmartGoalPlannerPage(goalToEdit: goal),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Notes Card if present
                  if (goal.notes.isNotEmpty) ...[
                    MMCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Goal Notes & Notes', style: AppTypography.headlineMedium),
                          const SizedBox(height: 8),
                          Text(goal.notes, style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],

                  // MoneyMateX AI Insights Banner
                  MMAIInsightCard(
                    title: 'MoneyMateX Goal Speedup Suggestion',
                    description: progress < 1.0
                        ? 'To reach your target of ${_formatRupees(goal.targetAmount)} by ${goal.targetDate}, save at least ${_formatRupees(requiredMonthly)} each month.'
                        : '🎉 Goal achieved! You have successfully reached your target for ${goal.name}.',
                    actionLabel: progress < 1.0 ? 'Add Deposit →' : 'View All Goals →',
                    onAction: progress < 1.0
                        ? () => _showContributionSheet(goal)
                        : () => context.go(AppRoutes.goals),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Contribution History Log Card
                  MMCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Goal Contributions', style: AppTypography.headlineMedium),
                        const SizedBox(height: AppSpacing.m),
                        if (goal.contributions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No contributions logged yet. Tap "+ Add Contribution" above to deposit funds.',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: goal.contributions.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1, color: AppColors.outlineVariant),
                            itemBuilder: (context, index) {
                              final record = goal.contributions[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.note.isNotEmpty ? record.note : 'Goal Deposit',
                                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '${record.date.day}/${record.date.month}/${record.date.year}',
                                          style: AppTypography.labelSmall,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '+${_formatRupees(record.amount)}',
                                      style: AppTypography.headlineMedium.copyWith(
                                        fontSize: 16,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
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

/// Analysis View for Goal Details
class SavingGoalAnalysisPage extends ConsumerWidget {
  final String id;
  const SavingGoalAnalysisPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SavingGoalDetailsPage(id: id);
  }
}

/// Goals Performance Overview Page
class SavingGoalsPerformancePage extends ConsumerWidget {
  const SavingGoalsPerformancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SavingGoalsOverviewPage();
  }
}

/// Goal Contribution Stub Page
class GoalContributionPage extends ConsumerWidget {
  const GoalContributionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SavingGoalsOverviewPage();
  }
}

/// Stub Emergency Fund Planner Page
class EmergencyFundPlannerPage extends StatelessWidget {
  const EmergencyFundPlannerPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Emergency Fund Planner')));
}

/// Stub Debt Payoff Planner Page
class DebtPayoffPlannerPage extends StatelessWidget {
  const DebtPayoffPlannerPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Debt Payoff Planner')));
}

/// Stitch Screen: MoneyMateX Budget Performance Analysis
/// Entry Point: Budget tab → Budget Performance
class BudgetPerformancePage extends ConsumerStatefulWidget {
  const BudgetPerformancePage({super.key});

  @override
  ConsumerState<BudgetPerformancePage> createState() => _BudgetPerformancePageState();
}

class _BudgetPerformancePageState extends ConsumerState<BudgetPerformancePage> {
  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final userProfile = ref.watch(userProfileProvider);

    final now = DateTime.now();
    final currentMonthExpenses = transactions.where((t) =>
      t.isExpense && t.date.year == now.year && t.date.month == now.month
    ).toList();

    final double totalSpent = currentMonthExpenses.fold(0.0, (sum, t) => sum + t.amount);
    final double targetBudget = userProfile.monthlyExpensesEstimate > 0 ? userProfile.monthlyExpensesEstimate : 50000.0;
    final double remainingBudget = (targetBudget - totalSpent).clamp(0.0, targetBudget);
    final double usageRatio = targetBudget > 0 ? (totalSpent / targetBudget).clamp(0.0, 1.5) : 0.0;
    final double usagePercent = usageRatio * 100;

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day;

    String budgetStatus;
    Color statusColor;
    Color statusBgColor;

    if (usagePercent > 100) {
      budgetStatus = 'Over Budget';
      statusColor = AppColors.error;
      statusBgColor = const Color(0xFFFFEBEE);
    } else if (usagePercent >= 80) {
      budgetStatus = 'Near Limit';
      statusColor = Colors.amber.shade900;
      statusBgColor = Colors.amber.shade100;
    } else {
      budgetStatus = 'Under Budget';
      statusColor = const Color(0xFF2E7D32);
      statusBgColor = const Color(0xFFE8F5E9);
    }

    // Category breakdown
    final Map<String, double> categorySpent = {};
    for (final t in currentMonthExpenses) {
      categorySpent[t.category] = (categorySpent[t.category] ?? 0.0) + t.amount;
    }

    final sortedCategories = categorySpent.entries.toList()
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
          'Budget Performance',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            tooltip: 'Add Expense',
            onPressed: () => context.go(AppRoutes.addExpense),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Budget Status',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track actual spending against monthly budget targets with dynamic progress metrics.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Budget Hero Summary Card
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
                            Text('CURRENT MONTHLY BUDGET', style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8)),
                            MMStatusChip(
                              label: budgetStatus,
                              backgroundColor: statusBgColor,
                              textColor: statusColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          _formatRupees(totalSpent),
                          style: AppTypography.display.copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          'Spent of ${_formatRupees(targetBudget)} Budget (${usagePercent.toStringAsFixed(1)}% Usage)',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        MMProgressBar(
                          progress: usageRatio.clamp(0.0, 1.0),
                          height: 10,
                          color: statusColor,
                        ),
                        const SizedBox(height: AppSpacing.m),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Remaining Budget', style: AppTypography.labelSmall),
                                const SizedBox(height: 2),
                                Text(
                                  _formatRupees(remainingBudget),
                                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 28, color: AppColors.outlineVariant),
                            Column(
                              children: [
                                Text('Days Remaining', style: AppTypography.labelSmall),
                                const SizedBox(height: 2),
                                Text(
                                  '$daysRemaining days',
                                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // MoneyMateX Budget Insight
                  MMAIInsightCard(
                    title: 'MoneyMateX Budget Insights',
                    description: usagePercent <= 80
                        ? 'Excellent control! You have used ${usagePercent.toStringAsFixed(1)}% of your monthly budget with $daysRemaining days left in the month.'
                        : usagePercent <= 100
                            ? 'Caution: You have reached ${usagePercent.toStringAsFixed(1)}% of your budget. Slow down spending in remaining $daysRemaining days.'
                            : 'Over Budget Alert: Expenses exceed your budget target by ${_formatRupees(totalSpent - targetBudget)}. Review high spending categories below.',
                    actionLabel: 'Review Transactions →',
                    onAction: () => context.go(AppRoutes.transactions),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Category Performance Breakdown
                  MMSectionHeader(
                    title: 'Category Spending Performance',
                    subtitle: '${sortedCategories.length} categories active this month',
                    actionLabel: '+ Add Expense',
                    onAction: () => context.go(AppRoutes.addExpense),
                  ),
                  const SizedBox(height: AppSpacing.s),

                  if (sortedCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: MMEmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'No Spending Logged This Month',
                        subtitle: 'Log expenses to see category budget usage and progress bars.',
                        actionLabel: '+ Log Expense',
                        onAction: () => context.go(AppRoutes.addExpense),
                      ),
                    )
                  else
                    ...sortedCategories.map((entry) {
                      final catName = entry.key;
                      final catSpent = entry.value;
                      final catShare = totalSpent > 0 ? (catSpent / totalSpent) : 0.0;

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
                                Text(catName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  '${_formatRupees(catSpent)} (${(catShare * 100).toStringAsFixed(1)}%)',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            MMProgressBar(progress: catShare.clamp(0.0, 1.0), height: 6),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: '+ Add New Expense',
                    onPressed: () => context.go(AppRoutes.addExpense),
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
}

/// Stub Budget Details Page
class BudgetDetailsPage extends StatelessWidget {
  final String category;
  const BudgetDetailsPage({super.key, required this.category});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Budget Details: $category')));
}
