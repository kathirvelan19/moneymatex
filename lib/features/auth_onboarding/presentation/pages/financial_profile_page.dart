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
import '../providers/user_profile_provider.dart';

/// Stitch Screen: MoneyMateX Financial Profile Screen
/// Entry Point: More → Financial Profile
class FinancialProfilePage extends ConsumerStatefulWidget {
  const FinancialProfilePage({super.key});

  @override
  ConsumerState<FinancialProfilePage> createState() => _FinancialProfilePageState();
}

class _FinancialProfilePageState extends ConsumerState<FinancialProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _incomeController;
  late TextEditingController _additionalIncomeController;
  late TextEditingController _expensesController;
  late TextEditingController _savingsController;
  late TextEditingController _debtController;

  late String _selectedOccupation;
  late String _selectedPriority;
  late String _selectedPrimaryGoal;

  final List<String> _occupations = const [
    'Professional',
    'Salaried Employee',
    'Business Owner',
    'Freelancer',
    'Student',
    'Retired',
    'Other',
  ];

  final List<String> _priorities = const [
    'Manage Expenses',
    'Build Emergency Reserve',
    'Grow Savings & Wealth',
    'Pay Off Debt',
    'Track Investments',
  ];

  final List<String> _goalsList = const [
    'Emergency Fund',
    'New Electronics / Phone',
    'Vacation & Travel',
    'Home & Rent',
    'Vehicle Purchase',
    'Investment & Wealth',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _incomeController = TextEditingController(text: profile.monthlyIncome > 0 ? profile.monthlyIncome.toStringAsFixed(0) : '');
    _additionalIncomeController = TextEditingController(text: profile.additionalIncome > 0 ? profile.additionalIncome.toStringAsFixed(0) : '');
    _expensesController = TextEditingController(text: profile.monthlyExpensesEstimate > 0 ? profile.monthlyExpensesEstimate.toStringAsFixed(0) : '');
    _savingsController = TextEditingController(text: profile.currentSavings > 0 ? profile.currentSavings.toStringAsFixed(0) : '');
    _debtController = TextEditingController(text: profile.debtAmount > 0 ? profile.debtAmount.toStringAsFixed(0) : '');

    _selectedOccupation = _occupations.contains(profile.occupation) ? profile.occupation : _occupations.first;
    _selectedPriority = _priorities.contains(profile.financialPriority) ? profile.financialPriority : _priorities.first;
    _selectedPrimaryGoal = _goalsList.contains(profile.primaryGoal) ? profile.primaryGoal : _goalsList.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _incomeController.dispose();
    _additionalIncomeController.dispose();
    _expensesController.dispose();
    _savingsController.dispose();
    _debtController.dispose();
    super.dispose();
  }

  void _onSaveProfile() {
    final profile = ref.read(userProfileProvider);
    final income = double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0.0;
    final addIncome = double.tryParse(_additionalIncomeController.text.replaceAll(',', '')) ?? 0.0;
    final expEst = double.tryParse(_expensesController.text.replaceAll(',', '')) ?? 0.0;
    final savings = double.tryParse(_savingsController.text.replaceAll(',', '')) ?? 0.0;
    final debt = double.tryParse(_debtController.text.replaceAll(',', '')) ?? 0.0;

    ref.read(userProfileProvider.notifier).updateUserInfo(
          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'User',
          email: _emailController.text.trim(),
        );

    ref.read(userProfileProvider.notifier).updateOccupation(_selectedOccupation);
    ref.read(userProfileProvider.notifier).updatePriority(_selectedPriority);
    ref.read(userProfileProvider.notifier).updateMonthlyIncome(income);
    ref.read(userProfileProvider.notifier).updateAdditionalIncome(addIncome);
    ref.read(userProfileProvider.notifier).updateMonthlyExpenses(expEst);
    ref.read(userProfileProvider.notifier).updateCurrentSavings(savings);
    ref.read(userProfileProvider.notifier).updateDebtAmount(debt);
    ref.read(userProfileProvider.notifier).updateGoal(_selectedPrimaryGoal, profile.goalTargetAmount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Financial profile updated successfully! All analytics updated.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);

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
          'Financial Profile',
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
                    'User Financial Profile',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configure your income, expense estimates, and financial goals. Changes propagate to all calculators & AI analytics.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Profile Header Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                            style: AppTypography.headlineLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.name, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                              Text(profile.email.isNotEmpty ? profile.email : 'Authenticated User', style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              MMStatusChip(
                                label: profile.occupation,
                                backgroundColor: AppColors.primaryFixed,
                                textColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Income & Employment Form
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
                        Text('INCOME & EMPLOYMENT', style: AppTypography.labelSmall),
                        const SizedBox(height: AppSpacing.m),

                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        DropdownButtonFormField<String>(
                          value: _selectedOccupation,
                          decoration: const InputDecoration(
                            labelText: 'Occupation / Employment Status',
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          items: _occupations.map((occ) {
                            return DropdownMenuItem(value: occ, child: Text(occ));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedOccupation = val);
                          },
                        ),
                        const SizedBox(height: AppSpacing.m),

                        TextField(
                          controller: _incomeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Base Monthly Income (₹)',
                            prefixText: '₹ ',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        TextField(
                          controller: _additionalIncomeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Additional Monthly Income (Freelance / Investments) (₹)',
                            prefixText: '₹ ',
                            prefixIcon: Icon(Icons.add_card_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // Expenses, Savings & Priorities Form
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
                        Text('EXPENSES, SAVINGS & PRIORITIES', style: AppTypography.labelSmall),
                        const SizedBox(height: AppSpacing.m),

                        TextField(
                          controller: _expensesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Monthly Expenses Estimate / Target Budget (₹)',
                            prefixText: '₹ ',
                            prefixIcon: Icon(Icons.receipt_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        TextField(
                          controller: _savingsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Current Total Savings Reserve (₹)',
                            prefixText: '₹ ',
                            prefixIcon: Icon(Icons.savings_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        TextField(
                          controller: _debtController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Existing Debt / Loans Amount (₹)',
                            prefixText: '₹ ',
                            prefixIcon: Icon(Icons.money_off_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),

                        DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Primary Financial Priority',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items: _priorities.map((pri) {
                            return DropdownMenuItem(value: pri, child: Text(pri));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPriority = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  MMButton(
                    label: 'Save Profile Changes',
                    onPressed: _onSaveProfile,
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
                        context.go(AppRoutes.settings);
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
