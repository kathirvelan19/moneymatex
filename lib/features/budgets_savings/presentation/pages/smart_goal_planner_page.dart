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
import '../../../../core/widgets/mm_text_field.dart';
import '../providers/goals_provider.dart';

/// Screen 5 — Smart Goal Planner Page
class SmartGoalPlannerPage extends ConsumerStatefulWidget {
  const SmartGoalPlannerPage({super.key});

  @override
  ConsumerState<SmartGoalPlannerPage> createState() => _SmartGoalPlannerPageState();
}

class _SmartGoalPlannerPageState extends ConsumerState<SmartGoalPlannerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentSavedController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _category = 'Emergency Fund';
  String _priority = 'Medium';
  String? _nameError;
  String? _targetAmountError;
  String? _dateError;

  final List<String> _categories = const [
    'Emergency Fund',
    'Vacation & Travel',
    'Home Purchase',
    'Vehicle',
    'Education',
    'Retirement',
    'Other',
  ];

  final List<String> _priorities = const ['High', 'Medium', 'Low'];

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentSavedController.dispose();
    _targetDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Calculated values based strictly on real user input
  double get _targetAmount => double.tryParse(_targetAmountController.text.trim()) ?? 0.0;
  double get _currentSaved => double.tryParse(_currentSavedController.text.trim()) ?? 0.0;
  double get _remainingAmount => (_targetAmount - _currentSaved).clamp(0.0, _targetAmount);

  int get _monthsRemaining {
    final dateStr = _targetDateController.text.trim();
    if (dateStr.isEmpty) return 12; // default 12 months fallback for calculations
    final parsedDate = DateTime.tryParse(dateStr);
    if (parsedDate == null) return 12;
    final now = DateTime.now();
    final days = parsedDate.difference(now).inDays;
    return (days / 30).ceil().clamp(1, 120);
  }

  double get _requiredMonthlyContribution => _monthsRemaining > 0 ? (_remainingAmount / _monthsRemaining) : _remainingAmount;
  double get _requiredWeeklyContribution => (_monthsRemaining * 4.33) > 0 ? (_remainingAmount / (_monthsRemaining * 4.33)) : _remainingAmount;

  void _validateAndCreateGoal() {
    final name = _nameController.text.trim();
    final targetStr = _targetAmountController.text.trim();
    final dateStr = _targetDateController.text.trim();

    bool valid = true;
    setState(() {
      _nameError = null;
      _targetAmountError = null;
      _dateError = null;
    });

    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter a goal name.');
      valid = false;
    }

    final targetVal = double.tryParse(targetStr);
    if (targetVal == null || targetVal <= 0) {
      setState(() => _targetAmountError = 'Target amount must be greater than zero.');
      valid = false;
    }

    if (dateStr.isNotEmpty) {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null && parsed.isBefore(DateTime.now())) {
        setState(() => _dateError = 'Choose a future target date.');
        valid = false;
      }
    }

    if (!valid) return;

    final newGoal = GoalItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      targetAmount: _targetAmount,
      savedAmount: _currentSaved,
      targetDate: dateStr.isEmpty ? '31 Dec 2026' : dateStr,
      category: _category,
      priority: _priority,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: _currentSaved >= _targetAmount ? 'Completed' : 'In Progress',
    );

    ref.read(goalsProvider.notifier).addGoal(newGoal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "${newGoal.name}" created successfully!'),
        backgroundColor: AppColors.primary,
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.goals);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Smart Goal Planner',
          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculate required monthly contributions and create a plan for your savings targets.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),

            MMTextField(
              label: 'Goal Name',
              hint: '[ Enter goal name e.g. Emergency Fund ]',
              controller: _nameController,
              errorText: _nameError,
              onChanged: (val) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),

            const SizedBox(height: AppSpacing.m),

            MMTextField(
              label: 'Target Amount (₹)',
              hint: '[ Enter target amount ]',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: _targetAmountController,
              errorText: _targetAmountError,
              onChanged: (val) {
                if (_targetAmountError != null) setState(() => _targetAmountError = null);
              },
            ),

            const SizedBox(height: AppSpacing.m),

            MMTextField(
              label: 'Current Saved Amount (₹)',
              hint: '[ Enter current savings (Optional) ]',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: _currentSavedController,
              onChanged: (val) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.m),

            MMTextField(
              label: 'Target Date',
              hint: '[ Select target date e.g. 2026-12-31 ]',
              controller: _targetDateController,
              errorText: _dateError,
              onChanged: (val) {
                if (_dateError != null) setState(() => _dateError = null);
              },
            ),

            const SizedBox(height: AppSpacing.m),

            Text('Category', style: AppTypography.labelSmall),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                fillColor: AppColors.surfaceContainerLow,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),

            const SizedBox(height: AppSpacing.m),

            Text('Priority Level', style: AppTypography.labelSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: _priorities.map((p) {
                final sel = _priority == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: sel,
                  selectedColor: AppColors.primaryContainer,
                  labelStyle: TextStyle(color: sel ? AppColors.primary : AppColors.onSurface),
                  onSelected: (val) {
                    if (val) setState(() => _priority = p);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.stackLg),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.m),

            // Real-Time Calculated Plan Projection Card
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
                      Text(
                        'SAVINGS PLAN PROJECTION',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 0.8),
                      ),
                      MMStatusChip(
                        label: '$_monthsRemaining Months',
                        backgroundColor: AppColors.primaryContainer,
                        textColor: AppColors.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.m),

                  _buildProjectionRow('Remaining Target', '₹${_remainingAmount.toInt()}'),
                  const Divider(color: AppColors.outlineVariant),
                  _buildProjectionRow(
                    'Required Monthly Contribution',
                    '₹${_requiredMonthlyContribution.toInt()}/mo',
                    highlight: true,
                  ),
                  const Divider(color: AppColors.outlineVariant),
                  _buildProjectionRow('Required Weekly Contribution', '₹${_requiredWeeklyContribution.toInt()}/wk'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.stackLg),

            MMButton(
              label: 'Create Goal',
              onPressed: _validateAndCreateGoal,
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: highlight ? 18 : 15,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.primary : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
