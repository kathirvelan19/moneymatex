import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../ai_assistant/presentation/widgets/k2i_chatbot_widget.dart';

/// MoneyMateX Modern Help & Support Center Page
/// Navigation: More → Help & Support
class HelpSupportCenterPage extends StatefulWidget {
  const HelpSupportCenterPage({super.key});

  @override
  State<HelpSupportCenterPage> createState() => _HelpSupportCenterPageState();
}

class _HelpSupportCenterPageState extends State<HelpSupportCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Track feedback for each FAQ index: true = helpful, false = not helpful, null = unvoted
  final Map<int, bool?> _faqFeedback = {};

  final List<String> _categories = const [
    'All',
    'Wallets & Accounts',
    'Transactions & Expenses',
    'Budget & Spending',
    'Goals & Savings',
    'K2i AI Advisor',
    'Privacy & Security',
  ];

  final List<Map<String, String>> _quickCategoryCards = const [
    {
      'title': 'Wallets & Accounts',
      'icon': 'account_balance_wallet',
      'count': '6 guides',
      'description': 'Adding bank accounts, credit cards & wallet balances',
      'category': 'Wallets & Accounts',
    },
    {
      'title': 'Transactions & Scan',
      'icon': 'receipt_long',
      'count': '8 guides',
      'description': 'UPI scanning, receipt OCR, auto-categorization',
      'category': 'Transactions & Expenses',
    },
    {
      'title': 'Budgets & Limits',
      'icon': 'pie_chart',
      'count': '5 guides',
      'description': 'Setting monthly targets & overspend alert notifications',
      'category': 'Budget & Spending',
    },
    {
      'title': 'Savings & Goals',
      'icon': 'savings',
      'count': '7 guides',
      'description': 'Goal velocity, emergency funds & contribution logs',
      'category': 'Goals & Savings',
    },
    {
      'title': 'K2i AI Intelligence',
      'icon': 'psychology',
      'count': '4 guides',
      'description': 'Deterministic data processing & financial health scoring',
      'category': 'K2i AI Advisor',
    },
    {
      'title': 'Security & Privacy',
      'icon': 'shield',
      'count': '5 guides',
      'description': 'Data encryption, user isolation & privacy settings',
      'category': 'Privacy & Security',
    },
  ];

  final List<Map<String, String>> _faqs = const [
    {
      'category': 'K2i AI Advisor',
      'question': 'How does K2i analyze my financial data?',
      'answer': 'K2i processes your actual logged transactions, wallet balances, and budget targets deterministically. It calculates metrics locally and explains your financial health without inventing data.',
    },
    {
      'category': 'K2i AI Advisor',
      'question': 'Does K2i generate fake financial numbers?',
      'answer': 'No! K2i strictly uses the authenticated user’s stored data. If you have no transactions or goals logged yet, K2i will prompt you to add them.',
    },
    {
      'category': 'Wallets & Accounts',
      'question': 'How do I add a new bank account or digital wallet?',
      'answer': 'Go to More → Wallets & Accounts and tap "+ Add Wallet". Select your account type, name, and opening balance.',
    },
    {
      'category': 'Wallets & Accounts',
      'question': 'How is my wallet balance calculated?',
      'answer': 'Your wallet balance is dynamically computed as: Opening Balance + Total Income Inflows - Total Expense Outflows.',
    },
    {
      'category': 'Transactions & Expenses',
      'question': 'How does the receipt OCR scanner work?',
      'answer': 'Tap the camera button on the bottom bar, capture or upload a paper receipt, and our OCR engine extracts merchant name, date, total amount, and line items automatically for instant expense logging.',
    },
    {
      'category': 'Transactions & Expenses',
      'question': 'Can I edit or delete logged transactions?',
      'answer': 'Yes! Open any transaction from the Transactions tab or detail view and tap "Edit" or "Delete". Your wallet balances and budget trackers update instantly.',
    },
    {
      'category': 'Budget & Spending',
      'question': 'How do I set up my monthly budget?',
      'answer': 'Go to More → Financial Profile and enter your Monthly Expenses Estimate. Your Budget Performance screen will automatically track actual spending against this target.',
    },
    {
      'category': 'Budget & Spending',
      'question': 'What happens when I exceed my monthly category limit?',
      'answer': 'MoneyMateX alerts you with an overspend notification and highlights the category in red in your Budget Performance dashboard, while K2i suggests budget adjustment recommendations.',
    },
    {
      'category': 'Goals & Savings',
      'question': 'How do savings goal contributions work?',
      'answer': 'Open any goal in the Goals tab and tap "+ Add Contribution". Adding funds increases your saved total and updates your required monthly velocity.',
    },
    {
      'category': 'Goals & Savings',
      'question': 'What is required savings velocity?',
      'answer': 'Required velocity is the calculated monthly savings amount needed to reach your target goal by your selected deadline.',
    },
    {
      'category': 'Privacy & Security',
      'question': 'Is my financial data stored securely?',
      'answer': 'Yes! All financial records are scoped exclusively to your authenticated User ID. Your data is isolated and protected using industry-standard JWT authorization and encryption.',
    },
    {
      'category': 'Privacy & Security',
      'question': 'How can I export or erase my financial data?',
      'answer': 'Navigate to More → Settings → Privacy & Data Center where you can download your full JSON financial export or request permanent account data wipe.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIconData(String iconName) {
    switch (iconName) {
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'pie_chart':
        return Icons.pie_chart_outline;
      case 'savings':
        return Icons.savings_outlined;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'shield':
        return Icons.shield_outlined;
      default:
        return Icons.help_outline;
    }
  }

  void _showSystemStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MoneyMateX System Status',
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'All core backend systems, AI inference models, and cloud database engines are performing normally.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.l),
              _buildStatusRow('REST API Gateway', 'Operational (99.99%)'),
              _buildStatusRow('K2i AI Intelligence Engine', 'Operational (99.98%)'),
              _buildStatusRow('Receipt OCR Scanner', 'Operational (100%)'),
              _buildStatusRow('Cloud Database Sync', 'Operational (99.99%)'),
              const SizedBox(height: AppSpacing.l),
              MMButton(
                label: 'Close Status Panel',
                onPressed: () => Navigator.pop(context),
                type: MMButtonType.secondary,
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String service, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(service, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 6),
              Text(status, style: AppTypography.labelSmall.copyWith(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _showSubmitTicketBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedTicketCategory = 'Wallets & Accounts';
    String priority = 'Normal';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.l,
                right: AppSpacing.l,
                top: AppSpacing.l,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Submit Support Ticket',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Text(
                        'Describe your issue or feedback. Our support engineering team typically responds within 2 hours.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      Text('ISSUE CATEGORY', style: AppTypography.labelSmall.copyWith(letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedTicketCategory,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            borderSide: const BorderSide(color: AppColors.outlineVariant),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Wallets & Accounts', child: Text('Wallets & Accounts')),
                          DropdownMenuItem(value: 'Transactions & Scan', child: Text('Transactions & Scan')),
                          DropdownMenuItem(value: 'Budget & Goals', child: Text('Budget & Goals')),
                          DropdownMenuItem(value: 'K2i AI Advisor', child: Text('K2i AI Advisor')),
                          DropdownMenuItem(value: 'Security & Privacy', child: Text('Security & Privacy')),
                          DropdownMenuItem(value: 'Other / Feedback', child: Text('Other / Feedback')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedTicketCategory = val);
                        },
                      ),

                      const SizedBox(height: AppSpacing.m),

                      Text('SUBJECT / TITLE', style: AppTypography.labelSmall.copyWith(letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: titleController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a brief subject' : null,
                        decoration: InputDecoration(
                          hintText: 'e.g., Unable to sync bank wallet balance',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            borderSide: const BorderSide(color: AppColors.outlineVariant),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.m),

                      Text('DESCRIPTION DETAILS', style: AppTypography.labelSmall.copyWith(letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        validator: (val) => val == null || val.trim().length < 10 ? 'Please enter at least 10 characters detailing your issue' : null,
                        decoration: InputDecoration(
                          hintText: 'Please detail what happened, steps to reproduce, or any error message received...',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            borderSide: const BorderSide(color: AppColors.outlineVariant),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.m),

                      Text('PRIORITY LEVEL', style: AppTypography.labelSmall.copyWith(letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Row(
                        children: ['Low', 'Normal', 'Urgent'].map((p) {
                          final isSel = priority == p;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(p),
                              selected: isSel,
                              selectedColor: AppColors.primaryContainer,
                              backgroundColor: AppColors.surfaceContainerLow,
                              labelStyle: TextStyle(
                                color: isSel ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) => setModalState(() => priority = p),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: AppSpacing.l),

                      MMButton(
                        label: isSubmitting ? 'Submitting Ticket...' : 'Submit Support Ticket',
                        icon: Icons.send_rounded,
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setModalState(() => isSubmitting = true);
                                  await Future.delayed(const Duration(milliseconds: 1000));
                                  if (context.mounted) {
                                    final ticketId = 'MMX-${10000 + Random().nextInt(89999)}';
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.primary,
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.white),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'Ticket $ticketId submitted successfully! We will contact your email shortly.',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                }
                              },
                        type: MMButtonType.primary,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final matchesCategory = _selectedCategory == 'All' || faq['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq['category']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

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
          'Help & Support Center',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Operational Pill Action
          InkWell(
            onTap: () => _showSystemStatusBottomSheet(context),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Operational',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
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
            constraints: const BoxConstraints(maxWidth: 850),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO BANNER CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How can we help you today?',
                                    style: AppTypography.headlineLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Search articles or talk with K2i AI Advisor 24/7.',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search Field in Hero Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search help topics, FAQs, receipts, wallets...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: AppColors.onSurfaceVariant),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // 4 QUICK ACTION BUTTON CARDS
                  Text(
                    'QUICK SUPPORT OPTIONS',
                    style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.s),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 550;
                      return GridView.count(
                        crossAxisCount: isWide ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: isWide ? 1.4 : 1.35,
                        children: [
                          _buildQuickActionCard(
                            context: context,
                            title: 'Ask K2i AI',
                            subtitle: 'Instant AI answers',
                            icon: Icons.psychology,
                            badge: '24/7 AI',
                            color: AppColors.aiAccent,
                            onTap: () => K2iChatbotBottomSheet.show(context),
                          ),
                          _buildQuickActionCard(
                            context: context,
                            title: 'Submit Ticket',
                            subtitle: 'Get human assist',
                            icon: Icons.confirmation_number_outlined,
                            badge: 'Fast',
                            color: AppColors.primary,
                            onTap: () => _showSubmitTicketBottomSheet(context),
                          ),
                          _buildQuickActionCard(
                            context: context,
                            title: 'System Status',
                            subtitle: '99.98% Uptime',
                            icon: Icons.sensors_outlined,
                            badge: 'Live',
                            color: Colors.green.shade700,
                            onTap: () => _showSystemStatusBottomSheet(context),
                          ),
                          _buildQuickActionCard(
                            context: context,
                            title: 'Email Us',
                            subtitle: 'support@monematex.com',
                            icon: Icons.mail_outline,
                            badge: 'Direct',
                            color: AppColors.tertiary,
                            onTap: () {
                              Clipboard.setData(const ClipboardData(text: 'support@monematex.com'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Support email copied to clipboard! (support@monematex.com)'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // BROWSE BY CATEGORY GRID
                  Text(
                    'BROWSE HELP CATEGORIES',
                    style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.s),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: _quickCategoryCards.length,
                        itemBuilder: (context, idx) {
                          final cat = _quickCategoryCards[idx];
                          final isSelected = _selectedCategory == cat['category'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat['category']!;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.12) : AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        _getCategoryIconData(cat['icon']!),
                                        color: isSelected ? AppColors.primary : AppColors.secondary,
                                        size: 22,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerHigh,
                                          borderRadius: BorderRadius.circular(AppRadius.full),
                                        ),
                                        child: Text(
                                          cat['count']!,
                                          style: AppTypography.labelSmall.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat['title']!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cat['description']!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontSize: 10,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // CATEGORY FILTER CHIPS BAR
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MMCategoryChip(
                            label: cat,
                            isSelected: _selectedCategory == cat,
                            onSelected: () => setState(() => _selectedCategory = cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // FREQUENTLY ASKED QUESTIONS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FREQUENTLY ASKED QUESTIONS',
                        style: AppTypography.labelSmall.copyWith(letterSpacing: 0.8, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${filteredFaqs.length} topics',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),

                  if (filteredFaqs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 40, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text(
                            'No help topics found matching "$_searchQuery"',
                            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try selecting "All" categories or ask K2i AI Advisor directly.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          MMButton(
                            label: 'Clear Search & Filters',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = 'All';
                              });
                            },
                            type: MMButtonType.secondary,
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredFaqs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final faq = entry.value;
                      final userVote = _faqFeedback[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.stackSm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.outlineVariant, width: 1),
                        ),
                        child: ExpansionTile(
                          shape: const Border(),
                          iconColor: AppColors.primary,
                          collapsedIconColor: AppColors.onSurfaceVariant,
                          title: Text(
                            faq['question']!,
                            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text(
                                    faq['category']!,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    faq['answer']!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(height: 1, color: AppColors.outlineVariant),
                                  const SizedBox(height: 10),

                                  // Feedback Section
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Was this answer helpful?',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (userVote != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.green, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Thank you for your feedback!',
                                              style: AppTypography.labelSmall.copyWith(
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () => setState(() => _faqFeedback[index] = true),
                                              borderRadius: BorderRadius.circular(AppRadius.m),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceContainerLow,
                                                  borderRadius: BorderRadius.circular(AppRadius.m),
                                                  border: Border.all(color: AppColors.outlineVariant),
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.primary),
                                                    SizedBox(width: 4),
                                                    Text('Yes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () => setState(() => _faqFeedback[index] = false),
                                              borderRadius: BorderRadius.circular(AppRadius.m),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceContainerLow,
                                                  borderRadius: BorderRadius.circular(AppRadius.m),
                                                  border: Border.all(color: AppColors.outlineVariant),
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.thumb_down_alt_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                                    SizedBox(width: 4),
                                                    Text('No', style: TextStyle(fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: AppSpacing.stackLg),

                  // FOOTER SUPPORT CONTACT CARD
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryFixed,
                              child: Icon(Icons.headset_mic, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Still need help?',
                                    style: AppTypography.headlineMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Our financial advisors are available 24 hours a day, 7 days a week.',
                                    style: AppTypography.bodyMedium.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: MMButton(
                                label: 'Ask K2i AI',
                                icon: Icons.psychology,
                                onPressed: () => K2iChatbotBottomSheet.show(context),
                                type: MMButtonType.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MMButton(
                                label: 'Submit Ticket',
                                icon: Icons.edit_document,
                                onPressed: () => _showSubmitTicketBottomSheet(context),
                                type: MMButtonType.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.l),

                  // APP INFO & LEGAL FOOTER
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'MoneyMateX v1.0.4 • Build 2026.8.31',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => context.go(AppRoutes.aboutLegalCenter),
                              child: const Text('Privacy Policy', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                            ),
                            const Text('•', style: TextStyle(color: AppColors.onSurfaceVariant)),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.aboutLegalCenter),
                              child: const Text('Terms of Service', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                            ),
                          ],
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

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias for HelpSupportPage
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});
  @override
  Widget build(BuildContext context) => const HelpSupportCenterPage();
}
