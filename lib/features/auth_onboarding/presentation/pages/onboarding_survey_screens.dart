import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../providers/user_profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../widgets/debt_option_card.dart';
import '../widgets/goal_option_card.dart';
import '../widgets/income_chip.dart';
import '../widgets/income_source_card.dart';
import '../widgets/occupation_card.dart';
import '../widgets/priority_card.dart';

/// Stitch Screen: MoneyMateX Occupation Screen (0ea6d6b84162412682f8b2d96948ecac)
/// Onboarding Step 1 — Occupation Selection
class OccupationPage extends StatefulWidget {
  const OccupationPage({super.key});

  @override
  State<OccupationPage> createState() => _OccupationPageState();
}

class _OccupationPageState extends State<OccupationPage> {
  String? _selectedOccupation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.priority),
            child: Text(
              'SKIP',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Header Section
                        Text(
                          'What best describes your work?',
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'This helps MoneyMateX tailor your financial insights and recommendations.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Options List
                        MMOccupationCard(
                          iconEmoji: '💼',
                          title: 'Salaried',
                          description: 'Regular employment income',
                          isSelected: _selectedOccupation == 'salaried',
                          onTap: () {
                            setState(() {
                              _selectedOccupation = 'salaried';
                            });
                          },
                        ),
                        MMOccupationCard(
                          iconEmoji: '🚀',
                          title: 'Self-Employed',
                          description: 'Independent professional or service provider',
                          isSelected: _selectedOccupation == 'self_employed',
                          onTap: () {
                            setState(() {
                              _selectedOccupation = 'self_employed';
                            });
                          },
                        ),
                        MMOccupationCard(
                          iconEmoji: '🏢',
                          title: 'Business Owner',
                          description: 'Own or operate a business',
                          isSelected: _selectedOccupation == 'business_owner',
                          onTap: () {
                            setState(() {
                              _selectedOccupation = 'business_owner';
                            });
                          },
                        ),
                        MMOccupationCard(
                          iconEmoji: '🎓',
                          title: 'Student',
                          description: 'Currently studying',
                          isSelected: _selectedOccupation == 'student',
                          onTap: () {
                            setState(() {
                              _selectedOccupation = 'student';
                            });
                          },
                        ),

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Footer & CTA Button
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Your answer helps us personalize your financial experience.',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Opacity(
                        opacity: _selectedOccupation != null ? 1.0 : 0.5,
                        child: MMPrimaryButton(
                          label: 'Continue',
                          onPressed: () {
                            if (_selectedOccupation != null) {
                              context.go(AppRoutes.priority);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Financial Priority Screen (f57fbdc263134b53ae17e48e973fa84e)
/// Onboarding Step 2 — Financial Priority Selection
class PriorityPage extends StatefulWidget {
  const PriorityPage({super.key});

  @override
  State<PriorityPage> createState() => _PriorityPageState();
}

class _PriorityPageState extends State<PriorityPage> {
  String? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.occupation);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.income),
            child: Text(
              'Skip',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Text(
                          "What's your biggest financial priority?",
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          "Choose what you'd like MoneyMateX to help you focus on first.",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Options Grid (Responsive LayoutBuilder for 1 or 2 columns)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 500;
                            final cardWidth = isWide
                                ? (constraints.maxWidth - AppSpacing.stackMd) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: AppSpacing.stackMd,
                              runSpacing: AppSpacing.stackMd,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: MMPriorityCard(
                                    icon: Icons.savings_outlined,
                                    title: 'Save More',
                                    description: 'Build your savings',
                                    isSelected: _selectedPriority == 'save',
                                    onTap: () => setState(() => _selectedPriority = 'save'),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: MMPriorityCard(
                                    icon: Icons.credit_card_outlined,
                                    title: 'Reduce Debt',
                                    description: 'Pay down loans faster',
                                    isSelected: _selectedPriority == 'debt',
                                    onTap: () => setState(() => _selectedPriority = 'debt'),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: MMPriorityCard(
                                    icon: Icons.trending_up,
                                    title: 'Build Investments',
                                    description: 'Grow your wealth',
                                    isSelected: _selectedPriority == 'invest',
                                    onTap: () => setState(() => _selectedPriority = 'invest'),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: MMPriorityCard(
                                    icon: Icons.track_changes,
                                    title: 'Plan for a Goal',
                                    description: 'Save for something important',
                                    isSelected: _selectedPriority == 'goal',
                                    onTap: () => setState(() => _selectedPriority = 'goal'),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: MMPriorityCard(
                                    icon: Icons.bar_chart_outlined,
                                    title: 'Track Spending',
                                    description: 'Understand where money goes',
                                    isSelected: _selectedPriority == 'track',
                                    onTap: () => setState(() => _selectedPriority = 'track'),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: MMPriorityCard(
                                    icon: Icons.shield_outlined,
                                    title: 'Emergency Fund',
                                    description: 'Prepare for unexpected costs',
                                    isSelected: _selectedPriority == 'emergency',
                                    onTap: () => setState(() => _selectedPriority = 'emergency'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: AppSpacing.stackMd),

                        // Microcopy Note
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'You can change your financial priority anytime.',
                                style: AppTypography.tagline.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Navigation Footer
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Continue Action Button
                      Opacity(
                        opacity: _selectedPriority != null ? 1.0 : 0.5,
                        child: MMPrimaryButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward,
                          onPressed: () {
                            if (_selectedPriority != null) {
                              context.go(AppRoutes.income);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Monthly Income Screen (372dbb84bf0047ddb9bbd53f15b9b73e)
/// Onboarding Step 3 — Monthly Income Selection
class IncomePage extends ConsumerStatefulWidget {
  const IncomePage({super.key});

  @override
  ConsumerState<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends ConsumerState<IncomePage> {
  final TextEditingController _incomeController = TextEditingController();
  String? _selectedChipLabel;

  final List<Map<String, dynamic>> _presets = const [
    {'label': '₹10K', 'value': 10000},
    {'label': '₹25K', 'value': 25000},
    {'label': '₹50K', 'value': 50000},
    {'label': '₹1L', 'value': 100000},
    {'label': '₹2L+', 'value': 200000},
  ];

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _selectPreset(String label, int value) {
    setState(() {
      _selectedChipLabel = label;
      _incomeController.text = value.toString();
    });
  }

  void _submitAndContinue() {
    final incomeText = _incomeController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(incomeText) ?? 0.0;
    ref.read(userProfileProvider.notifier).updateMonthlyIncome(amount);
    context.go(AppRoutes.incomeSources);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.priority);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.incomeSources),
            child: Text(
              'Skip',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 3),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Text(
                          "What's your monthly income?",
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'Tell us roughly how much money you receive each month. This helps us build a realistic financial plan for you.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Large Currency Input Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '₹',
                                style: AppTypography.display.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _incomeController,
                                  keyboardType: TextInputType.number,
                                  style: AppTypography.display.copyWith(
                                    color: AppColors.onBackground,
                                  ),
                                  onChanged: (_) {
                                    setState(() {
                                      _selectedChipLabel = null;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: AppTypography.display.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'Enter your average monthly income.',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Quick Select Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _presets.map((preset) {
                            final label = preset['label'] as String;
                            final val = preset['value'] as int;
                            return MMIncomeChip(
                              label: label,
                              isSelected: _selectedChipLabel == label,
                              onTap: () => _selectPreset(label, val),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Secondary Option: Irregular Income
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _incomeController.text = '0';
                                _selectedChipLabel = null;
                              });
                            },
                            child: Text(
                              "I don't have a regular income",
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MMPrimaryButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward,
                        onPressed: _submitAndContinue,
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Text(
                        'Your information is private and used only to personalize MoneyMateX.',
                        textAlign: TextAlign.center,
                        style: AppTypography.tagline.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Other Income Sources Screen (1b366b7108964f2c973eb299baa59533)
/// Onboarding Step 4 — Other Income Sources Selection
class IncomeSourcesPage extends StatefulWidget {
  const IncomeSourcesPage({super.key});

  @override
  State<IncomeSourcesPage> createState() => _IncomeSourcesPageState();
}

class _IncomeSourcesPageState extends State<IncomeSourcesPage> {
  final Set<String> _selectedSources = {'freelance'};
  final TextEditingController _amountController = TextEditingController(text: '15000');
  bool _isNoneSelected = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _toggleSource(String key) {
    setState(() {
      if (key == 'none') {
        _isNoneSelected = true;
        _selectedSources.clear();
      } else {
        _isNoneSelected = false;
        if (_selectedSources.contains(key)) {
          _selectedSources.remove(key);
        } else {
          _selectedSources.add(key);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveSources = !_isNoneSelected && _selectedSources.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.income);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.expenses),
            child: Text(
              'Skip',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 4),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Text(
                          'Do you have other sources of income?',
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'Knowing your full income picture helps MoneyMateX create a more accurate financial plan.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Options Grid (2 Columns)
                        Row(
                          children: [
                            Expanded(
                              child: MMIncomeSourceCard(
                                icon: Icons.laptop_mac,
                                title: 'Freelance',
                                description: 'Freelance or side work',
                                isSelected: !_isNoneSelected && _selectedSources.contains('freelance'),
                                onTap: () => _toggleSource('freelance'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.stackSm),
                            Expanded(
                              child: MMIncomeSourceCard(
                                icon: Icons.home_work_outlined,
                                title: 'Rental',
                                description: 'Rental income',
                                isSelected: !_isNoneSelected && _selectedSources.contains('rental'),
                                onTap: () => _toggleSource('rental'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Row(
                          children: [
                            Expanded(
                              child: MMIncomeSourceCard(
                                icon: Icons.trending_up,
                                title: 'Investments',
                                description: 'Dividends, interest or returns',
                                isSelected: !_isNoneSelected && _selectedSources.contains('investments'),
                                onTap: () => _toggleSource('investments'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.stackSm),
                            Expanded(
                              child: MMIncomeSourceCard(
                                icon: Icons.apartment,
                                title: 'Business',
                                description: 'Business income',
                                isSelected: !_isNoneSelected && _selectedSources.contains('business'),
                                onTap: () => _toggleSource('business'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Row(
                          children: [
                            Expanded(
                              child: MMIncomeSourceCard(
                                icon: Icons.auto_awesome,
                                title: 'Other',
                                description: 'Other income source',
                                isSelected: !_isNoneSelected && _selectedSources.contains('other'),
                                onTap: () => _toggleSource('other'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.stackSm),

                        // Full Width Option: None
                        MMIncomeSourceCard(
                          icon: Icons.block_outlined,
                          title: 'None, this is all my income',
                          description: '',
                          isSelected: _isNoneSelected,
                          fullWidth: true,
                          onTap: () => _toggleSource('none'),
                        ),

                        if (hasActiveSources) ...[
                          const SizedBox(height: AppSpacing.stackLg),

                          // Conditional Input Container for Secondary Income Amount
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(color: AppColors.outlineVariant, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Monthly Secondary Income (Optional)',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(AppRadius.l),
                                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '₹',
                                        style: AppTypography.bodyLarge.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _amountController,
                                          keyboardType: TextInputType.number,
                                          style: AppTypography.bodyLarge.copyWith(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: '0',
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MMPrimaryButton(
                        label: 'Continue',
                        onPressed: () => context.go(AppRoutes.expenses),
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Your information is used only to personalize your MoneyMateX experience.',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
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
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Monthly Expenses Screen (e146669d9ce144de944d9bc407dbb24b)
/// Onboarding Step 5 — Monthly Expenses Selection
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController _totalExpensesController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _transportController = TextEditingController();
  final TextEditingController _billsController = TextEditingController();

  bool _isBreakdownExpanded = false;
  String? _selectedChipLabel;

  final List<Map<String, dynamic>> _presets = const [
    {'label': '₹10K', 'value': 10000},
    {'label': '₹20K', 'value': 20000},
    {'label': '₹30K', 'value': 30000},
    {'label': '₹50K', 'value': 50000},
    {'label': '₹75K+', 'value': 75000},
  ];

  @override
  void dispose() {
    _totalExpensesController.dispose();
    _foodController.dispose();
    _transportController.dispose();
    _billsController.dispose();
    super.dispose();
  }

  void _selectPreset(String label, int value) {
    setState(() {
      _selectedChipLabel = label;
      _totalExpensesController.text = value.toString();
    });
  }

  int get _calculatedTotal {
    final food = int.tryParse(_foodController.text) ?? 0;
    final transport = int.tryParse(_transportController.text) ?? 0;
    final bills = int.tryParse(_billsController.text) ?? 0;
    return food + transport + bills;
  }

  void _updateFromBreakdown() {
    final total = _calculatedTotal;
    if (total > 0) {
      _totalExpensesController.text = total.toString();
      _selectedChipLabel = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.incomeSources);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.savings),
            child: Text(
              'Skip',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 5),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Text(
                          'How much do you spend each month?',
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'An estimate is enough. You can refine your spending categories later.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Average Monthly Expenses Label & Input Field
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'AVERAGE MONTHLY EXPENSES',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.stackSm),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(AppRadius.l),
                                  border: Border.all(color: AppColors.outlineVariant, width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '₹',
                                      style: AppTypography.display.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _totalExpensesController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.display.copyWith(
                                          color: AppColors.onBackground,
                                        ),
                                        onChanged: (_) {
                                          setState(() {
                                            _selectedChipLabel = null;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          hintStyle: AppTypography.display.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Quick Select Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _presets.map((preset) {
                            final label = preset['label'] as String;
                            final val = preset['value'] as int;
                            final isSelected = _selectedChipLabel == label;

                            return MMIncomeChip(
                              label: label,
                              isSelected: isSelected,
                              onTap: () => _selectPreset(label, val),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Smart Insight Card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Based on what you've shared, MoneyMateX estimates you could have approximately ",
                                      ),
                                      TextSpan(
                                        text: '₹20,000',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: ' left each month.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Expandable Breakdown Accordion Card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isBreakdownExpanded = !_isBreakdownExpanded;
                                  });
                                },
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Want to break it down?',
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      Icon(
                                        _isBreakdownExpanded ? Icons.expand_less : Icons.expand_more,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_isBreakdownExpanded)
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                                  decoration: const BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    border: Border(
                                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Food & Dining
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Text('🍔', style: TextStyle(fontSize: 18)),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Food & Dining',
                                                style: AppTypography.bodyMedium.copyWith(
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: TextField(
                                              controller: _foodController,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.right,
                                              onChanged: (_) => setState(_updateFromBreakdown),
                                              decoration: InputDecoration(
                                                prefixText: '₹ ',
                                                prefixStyle: AppTypography.bodyMedium.copyWith(
                                                  color: AppColors.onSurfaceVariant,
                                                ),
                                                hintText: '0',
                                                border: InputBorder.none,
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16, color: AppColors.outlineVariant),

                                      // Transport
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Text('🚗', style: TextStyle(fontSize: 18)),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Transport',
                                                style: AppTypography.bodyMedium.copyWith(
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: TextField(
                                              controller: _transportController,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.right,
                                              onChanged: (_) => setState(_updateFromBreakdown),
                                              decoration: InputDecoration(
                                                prefixText: '₹ ',
                                                prefixStyle: AppTypography.bodyMedium.copyWith(
                                                  color: AppColors.onSurfaceVariant,
                                                ),
                                                hintText: '0',
                                                border: InputBorder.none,
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16, color: AppColors.outlineVariant),

                                      // Bills & Utilities
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Text('🏠', style: TextStyle(fontSize: 18)),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Bills & Utilities',
                                                style: AppTypography.bodyMedium.copyWith(
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: TextField(
                                              controller: _billsController,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.right,
                                              onChanged: (_) => setState(_updateFromBreakdown),
                                              decoration: InputDecoration(
                                                prefixText: '₹ ',
                                                prefixStyle: AppTypography.bodyMedium.copyWith(
                                                  color: AppColors.onSurfaceVariant,
                                                ),
                                                hintText: '0',
                                                border: InputBorder.none,
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.m),

                                      // Total Breakdown Summary Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total estimated expenses',
                                            style: AppTypography.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '₹ $_calculatedTotal',
                                            style: AppTypography.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
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

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MMPrimaryButton(
                        label: 'Continue',
                        onPressed: () => context.go(AppRoutes.savings),
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Text(
                        'Estimates are okay. You can update these numbers anytime.',
                        textAlign: TextAlign.center,
                        style: AppTypography.tagline.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Current Savings Screen (180c0717889a45518e0e4325267762ce)
/// Onboarding Step 6 — Current Savings Selection
class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final TextEditingController _savingsController = TextEditingController();
  bool _hasNoSavings = false;
  String? _selectedChipLabel;

  final List<Map<String, dynamic>> _presets = const [
    {'label': '₹10K', 'value': 10000},
    {'label': '₹25K', 'value': 25000},
    {'label': '₹50K', 'value': 50000},
    {'label': '₹1L', 'value': 100000},
    {'label': '₹5L+', 'value': 500000},
  ];

  @override
  void dispose() {
    _savingsController.dispose();
    super.dispose();
  }

  void _selectPreset(String label, int value) {
    setState(() {
      _selectedChipLabel = label;
      _savingsController.text = value.toString();
      _hasNoSavings = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isZeroOrNoSavings = _hasNoSavings ||
        (_savingsController.text.isNotEmpty && (int.tryParse(_savingsController.text) ?? -1) == 0);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.expenses);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.debts),
            child: Text(
              'SKIP',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 6),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Text(
                          'How much have you saved so far?',
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'Give us an estimate of your current savings so we can understand your starting point and build a more realistic plan.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Current Savings Input Container
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT SAVINGS',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '₹',
                                    style: AppTypography.display.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _savingsController,
                                      keyboardType: TextInputType.number,
                                      style: AppTypography.display.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedChipLabel = null;
                                          if (val.isNotEmpty && (int.tryParse(val) ?? 0) > 0) {
                                            _hasNoSavings = false;
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: AppTypography.display.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackMd),

                        // Quick Select Preset Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _presets.map((preset) {
                            final label = preset['label'] as String;
                            final val = preset['value'] as int;
                            final isSelected = _selectedChipLabel == label;

                            return MMIncomeChip(
                              label: label,
                              isSelected: isSelected,
                              onTap: () => _selectPreset(label, val),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Option: I don't have any savings yet
                        InkWell(
                          onTap: () {
                            setState(() {
                              _hasNoSavings = !_hasNoSavings;
                              if (_hasNoSavings) {
                                _savingsController.text = '0';
                                _selectedChipLabel = null;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.cardPadding),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.l),
                              border: Border.all(
                                color: _hasNoSavings ? AppColors.primary : AppColors.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _hasNoSavings ? AppColors.primary : AppColors.outline,
                                      width: 2,
                                    ),
                                  ),
                                  child: _hasNoSavings
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "I don't have any savings yet",
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: _hasNoSavings ? AppColors.primary : AppColors.onSurface,
                                      fontWeight: _hasNoSavings ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (isZeroOrNoSavings) ...[
                          const SizedBox(height: AppSpacing.stackSm),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackSm),
                            child: Text(
                              "That's okay. Every financial journey starts somewhere.",
                              style: AppTypography.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MMPrimaryButton(
                        label: 'Continue',
                        onPressed: () => context.go(AppRoutes.debts),
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Text(
                        'Your savings information is private and used only to personalize your financial plan.',
                        textAlign: TextAlign.center,
                        style: AppTypography.tagline.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Existing Debt / Loans Screen (b24d6e6b926b4879a72e39d40b7266b6)
/// Onboarding Step 7 — Existing Debt / Loans Selection
class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  final Set<String> _selectedDebts = {};
  bool _isNoDebtSelected = false;

  final Map<String, TextEditingController> _outstandingControllers = {
    'home': TextEditingController(),
    'car': TextEditingController(),
    'personal': TextEditingController(),
    'creditcard': TextEditingController(),
    'other': TextEditingController(),
  };

  final Map<String, TextEditingController> _monthlyControllers = {
    'home': TextEditingController(),
    'car': TextEditingController(),
    'personal': TextEditingController(),
    'creditcard': TextEditingController(),
    'other': TextEditingController(),
  };

  @override
  void dispose() {
    for (var controller in _outstandingControllers.values) {
      controller.dispose();
    }
    for (var controller in _monthlyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleDebt(String key) {
    setState(() {
      if (key == 'none') {
        _isNoDebtSelected = true;
        _selectedDebts.clear();
      } else {
        _isNoDebtSelected = false;
        if (_selectedDebts.contains(key)) {
          _selectedDebts.remove(key);
        } else {
          _selectedDebts.add(key);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.savings);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.goalSelection),
            child: Text(
              'Skip',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 7),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Text(
                          'Do you currently have any debt or loans?',
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'This helps MoneyMateX create a realistic financial plan and prioritize your financial goals.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Debt Option Cards List
                        MMDebtOptionCard(
                          icon: Icons.home_outlined,
                          title: 'Home Loan',
                          description: 'Mortgage or housing loan',
                          isSelected: !_isNoDebtSelected && _selectedDebts.contains('home'),
                          onTap: () => _toggleDebt('home'),
                          outstandingController: _outstandingControllers['home'],
                          monthlyPaymentController: _monthlyControllers['home'],
                        ),
                        const SizedBox(height: AppSpacing.stackSm),

                        MMDebtOptionCard(
                          icon: Icons.directions_car_outlined,
                          title: 'Car Loan',
                          description: 'Vehicle financing',
                          isSelected: !_isNoDebtSelected && _selectedDebts.contains('car'),
                          onTap: () => _toggleDebt('car'),
                          outstandingController: _outstandingControllers['car'],
                          monthlyPaymentController: _monthlyControllers['car'],
                        ),
                        const SizedBox(height: AppSpacing.stackSm),

                        MMDebtOptionCard(
                          icon: Icons.person_outline,
                          title: 'Personal Loan',
                          description: 'Personal or consumer loan',
                          isSelected: !_isNoDebtSelected && _selectedDebts.contains('personal'),
                          onTap: () => _toggleDebt('personal'),
                          outstandingController: _outstandingControllers['personal'],
                          monthlyPaymentController: _monthlyControllers['personal'],
                        ),
                        const SizedBox(height: AppSpacing.stackSm),

                        MMDebtOptionCard(
                          icon: Icons.credit_card_outlined,
                          title: 'Credit Card Debt',
                          description: 'Outstanding credit card balance',
                          isSelected: !_isNoDebtSelected && _selectedDebts.contains('creditcard'),
                          onTap: () => _toggleDebt('creditcard'),
                          outstandingController: _outstandingControllers['creditcard'],
                          monthlyPaymentController: _monthlyControllers['creditcard'],
                        ),
                        const SizedBox(height: AppSpacing.stackSm),

                        MMDebtOptionCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Other Debt',
                          description: 'Any other outstanding debt',
                          isSelected: !_isNoDebtSelected && _selectedDebts.contains('other'),
                          onTap: () => _toggleDebt('other'),
                          outstandingController: _outstandingControllers['other'],
                          monthlyPaymentController: _monthlyControllers['other'],
                        ),
                        const SizedBox(height: AppSpacing.stackSm),

                        const Divider(height: 16, color: AppColors.outlineVariant),
                        const SizedBox(height: AppSpacing.stackSm),

                        // Option 6: No Debt (Mutually Exclusive)
                        MMDebtOptionCard(
                          icon: Icons.check_circle_outline,
                          title: 'No Debt',
                          description: "I currently don't have any debt",
                          isSelected: _isNoDebtSelected,
                          onTap: () => _toggleDebt('none'),
                          showDetailsPanel: false,
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Privacy Notice Box
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline, size: 20, color: AppColors.outline),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: Text(
                                  'Your debt information is private and used only to personalize your financial plan.',
                                  style: AppTypography.tagline.copyWith(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: MMSecondaryButton(
                          label: 'Previous',
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.savings);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.stackSm),
                      Expanded(
                        child: MMPrimaryButton(
                          label: 'Continue',
                          onPressed: () => context.go(AppRoutes.goalSelection),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Financial Goal Selection Screen (d9ccb8b5b74b45958aa7d33d39b9b06b)
/// Onboarding Step 10 — Financial Goal Selection
class GoalSelectionPage extends StatefulWidget {
  const GoalSelectionPage({super.key});

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> {
  String _selectedGoal = 'trip';

  final List<Map<String, dynamic>> _goals = const [
    {'id': 'phone', 'emoji': '📱', 'title': 'New smartphone'},
    {'id': 'computer', 'emoji': '💻', 'title': 'New computer'},
    {'id': 'trip', 'emoji': '✈️', 'title': 'Trip or vacation'},
    {'id': 'vehicle', 'emoji': '🏍️', 'title': 'Bike or car'},
    {'id': 'home', 'emoji': '🏠', 'title': 'Home or renovation'},
    {'id': 'education', 'emoji': '🎓', 'title': 'Course or education'},
    {'id': 'safety', 'emoji': '🛡️', 'title': 'Financial safety net'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.debts);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.goalTarget),
            child: Text(
              'Skip',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Text(
                          'What are you saving for?',
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'Tell us something you want to buy or achieve. MoneyMateX will help you create a realistic savings plan.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Options Grid (2 Columns)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = (constraints.maxWidth - AppSpacing.stackSm) / 2;

                            return Wrap(
                              spacing: AppSpacing.stackSm,
                              runSpacing: AppSpacing.stackSm,
                              children: [
                                ..._goals.map((g) {
                                  final id = g['id'] as String;
                                  final emoji = g['emoji'] as String;
                                  final title = g['title'] as String;

                                  return SizedBox(
                                    width: itemWidth,
                                    child: MMGoalOptionCard(
                                      emoji: emoji,
                                      title: title,
                                      isSelected: _selectedGoal == id,
                                      onTap: () => setState(() => _selectedGoal = id),
                                    ),
                                  );
                                }),
                                SizedBox(
                                  width: itemWidth,
                                  child: MMGoalOptionCard(
                                    icon: Icons.add,
                                    title: 'Create your own goal',
                                    isSelected: _selectedGoal == 'custom',
                                    isDashed: true,
                                    onTap: () => setState(() => _selectedGoal = 'custom'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Smart Message Card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Make it specific',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Once you set your target amount and date, MoneyMateX can calculate how much you should save each month.',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: MMPrimaryButton(
                    label: 'Set My Goal',
                    onPressed: () => context.go(AppRoutes.goalTarget),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Goal Amount & Target Date Screen (4500bf00d9d34b38ae1b895c6f3f031b)
/// Onboarding Step 10 — Goal Target Amount & Target Date
class GoalTargetPage extends ConsumerStatefulWidget {
  const GoalTargetPage({super.key});

  @override
  ConsumerState<GoalTargetPage> createState() => _GoalTargetPageState();
}

class _GoalTargetPageState extends ConsumerState<GoalTargetPage> {
  final TextEditingController _amountController = TextEditingController(text: '60,000');
  final TextEditingController _dateController = TextEditingController(text: 'Sep 2024');

  String? _selectedAmountChip = '₹50K';
  String? _selectedDateChip = '3 Months';

  final List<Map<String, dynamic>> _amountPresets = const [
    {'label': '₹25K', 'value': '25,000'},
    {'label': '₹50K', 'value': '50,000'},
    {'label': '₹75K', 'value': '75,000'},
    {'label': '₹1L', 'value': '1,00,000'},
    {'label': '₹2L', 'value': '2,00,000'},
  ];

  final List<Map<String, String>> _datePresets = const [
    {'label': 'Next Month', 'value': 'Oct 2024'},
    {'label': '3 Months', 'value': 'Dec 2024'},
    {'label': '6 Months', 'value': 'Mar 2025'},
    {'label': '1 Year', 'value': 'Sep 2025'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _selectAmountPreset(String label, String value) {
    setState(() {
      _selectedAmountChip = label;
      _amountController.text = value;
    });
  }

  void _selectDatePreset(String label, String value) {
    setState(() {
      _selectedDateChip = label;
      _dateController.text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.goalSelection);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.onboardingSummary),
            child: Text(
              'Skip',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 9),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceContainerLow,
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.smartphone,
                                  size: 32,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.m),
                              Text(
                                "Let's set your target.",
                                textAlign: TextAlign.center,
                                style: AppTypography.headlineMobile.copyWith(
                                  color: AppColors.onBackground,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 280),
                                child: Text(
                                  "Tell us how much you need and when you'd like to reach your goal.",
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Section 1: Goal Amount Input
                        Text(
                          'HOW MUCH WILL IT COST?',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '₹',
                                style: AppTypography.headlineMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  style: AppTypography.headlineMobile.copyWith(
                                    color: AppColors.onBackground,
                                  ),
                                  onChanged: (_) => setState(() => _selectedAmountChip = null),
                                  decoration: InputDecoration(
                                    hintText: '60,000',
                                    hintStyle: AppTypography.headlineMobile.copyWith(
                                      color: AppColors.outline.withValues(alpha: 0.5),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _amountPresets.map((preset) {
                              final label = preset['label'] as String;
                              final val = preset['value'] as String;
                              final isSelected = _selectedAmountChip == label;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: MMIncomeChip(
                                  label: label,
                                  isSelected: isSelected,
                                  onTap: () => _selectAmountPreset(label, val),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Section 2: Target Date Input
                        Text(
                          'WHEN DO YOU WANT TO ACHIEVE IT?',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _dateController,
                                  readOnly: true,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.onBackground,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Select target date',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _datePresets.map((preset) {
                              final label = preset['label']!;
                              final val = preset['value']!;
                              final isSelected = _selectedDateChip == label;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: MMIncomeChip(
                                  label: label,
                                  isSelected: isSelected,
                                  onTap: () => _selectDatePreset(label, val),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Section 3: Savings Plan Card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.insights,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'YOUR SAVINGS PLAN',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.m),
                              Text(
                                'Suggested saving:',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '₹20,000',
                                    style: AppTypography.headlineMobile.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '/ month',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '≈ ₹666 / day',
                                style: AppTypography.tagline.copyWith(
                                  color: AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackMd),

                        // Section 4: Affordability Insight Box
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Color(0xFF166534),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'This goal looks achievable with your current estimated cash flow.',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: const Color(0xFF166534),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () {},
                                      child: Text(
                                        'Adjust parameters',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: const Color(0xFF166534),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Area
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MMPrimaryButton(
                        label: 'Continue to Summary',
                        onPressed: () => context.go(AppRoutes.onboardingSummary),
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.onboardingSummary),
                        child: Text(
                          'Skip for now',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch Screen: MoneyMateX Financial Onboarding Plan Summary (Step 10 of 10)
class OnboardingSummaryPage extends ConsumerWidget {
  const OnboardingSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.goalTarget);
            }
          },
        ),
        title: Text(
          'MoneyMateX',
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
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const OnboardingProgressIndicator(currentStep: 10),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.s),

                        // Header Section
                        Text(
                          'Your Personalized Financial Plan is Ready! 🎉',
                          style: AppTypography.headlineMobile.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          "We've tailored MoneyMateX based on your answers to help you achieve your financial goals.",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),

                        // Plan Summary Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outlineVariant, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FINANCIAL PROFILE SUMMARY',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.m),

                              _SummaryRow(
                                icon: Icons.work_outline,
                                label: 'Occupation',
                                value: profile.occupation,
                              ),
                              const Divider(height: 16, color: AppColors.outlineVariant),

                              _SummaryRow(
                                icon: Icons.flag_outlined,
                                label: 'Top Priority',
                                value: profile.financialPriority,
                              ),
                              const Divider(height: 16, color: AppColors.outlineVariant),

                              _SummaryRow(
                                icon: Icons.payments_outlined,
                                label: 'Monthly Income',
                                value: profile.monthlyIncome > 0
                                    ? '₹ ${profile.monthlyIncome.toStringAsFixed(0)}'
                                    : 'Not set',
                              ),
                              const Divider(height: 16, color: AppColors.outlineVariant),

                              _SummaryRow(
                                icon: Icons.receipt_long_outlined,
                                label: 'Estimated Expenses',
                                value: profile.monthlyExpensesEstimate > 0
                                    ? '₹ ${profile.monthlyExpensesEstimate.toStringAsFixed(0)}'
                                    : 'Not set',
                              ),
                              const Divider(height: 16, color: AppColors.outlineVariant),

                              _SummaryRow(
                                icon: Icons.savings_outlined,
                                label: 'Savings Reserve',
                                value: profile.currentSavings > 0
                                    ? '₹ ${profile.currentSavings.toStringAsFixed(0)}'
                                    : 'Not set',
                              ),
                              const Divider(height: 16, color: AppColors.outlineVariant),

                              _SummaryRow(
                                icon: Icons.ads_click,
                                label: 'Primary Goal',
                                value: profile.primaryGoal,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.stackLg),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Area
                Container(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant, width: 1),
                    ),
                  ),
                  child: MMPrimaryButton(
                    label: 'Complete & Launch Dashboard',
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).completeOnboarding();
                      if (context.mounted) {
                        context.go(AppRoutes.dashboard);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


