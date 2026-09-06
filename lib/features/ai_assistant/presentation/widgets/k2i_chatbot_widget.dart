import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/financial_analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class K2iChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  K2iChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Centralized Reusable K2i AI Chatbot Component
class K2iChatbotWidget extends ConsumerStatefulWidget {
  final String? initialQuery;

  const K2iChatbotWidget({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<K2iChatbotWidget> createState() => _K2iChatbotWidgetState();
}

class _K2iChatbotWidgetState extends ConsumerState<K2iChatbotWidget> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<K2iChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _suggestedPrompts = const [
    'How much did I spend this month?',
    'What is the 50/30/20 rule?',
    'What is my financial health score?',
    'What is Buddy?',
    'How to scan a receipt?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      K2iChatMessage(
        text: '''📌 SUMMARY
Hello! I am K2i, your MoneyMateX AI Financial Buddy & Intelligence Assistant.

📊 BREAKDOWN & DETAILS
• Live Financial Analysis: Review balance, income, expenses, and savings rate.
• Personal Finance Coaching: Advice on 50/30/20 rule, emergency funds, and SIPs.
• App Features: Guidance on Receipt OCR, UPI scanner, and Report exports.

💡 RECOMMENDED ACTION
Ask me any question below or select a suggested topic to get started!''',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String queryText) async {
    final text = queryText.trim();
    if (text.isEmpty || _isLoading) return;

    _inputController.clear();

    setState(() {
      _messages.add(K2iChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final analytics = ref.read(financialAnalyticsProvider);
      final aiService = ref.read(aiServiceProvider);
      final responseText = await aiService.generateAdvisoryResponse(
        prompt: text,
        contextData: {'financialContext': analytics.buildK2iFinancialContextPrompt()},
      );

      if (mounted) {
        setState(() {
          _messages.add(K2iChatMessage(text: responseText, isUser: false, timestamp: DateTime.now()));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(
            K2iChatMessage(
              text: '''📌 SUMMARY
K2i AI Assistant is ready to help you.

📊 BREAKDOWN & DETAILS
• Network / API fallback engaged.

💡 RECOMMENDED ACTION
Please try again or select one of the suggested topics below!''',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  Widget _buildFormattedText(String text, bool isUser) {
    if (isUser) {
      return Text(
        text,
        style: AppTypography.bodyMedium.copyWith(color: Colors.white),
      );
    }

    final lines = text.split('\n');
    final List<Widget> children = [];

    for (final line in lines) {
      if (line.startsWith('📌 SUMMARY')) {
        children.add(
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Text(
              '📌 SUMMARY',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        );
      } else if (line.startsWith('📊 BREAKDOWN & DETAILS')) {
        children.add(const SizedBox(height: 8));
        children.add(
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Text(
              '📊 BREAKDOWN & DETAILS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        );
      } else if (line.startsWith('💡 RECOMMENDED ACTION')) {
        children.add(const SizedBox(height: 8));
        children.add(
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Text(
              '💡 RECOMMENDED ACTION',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onTertiaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        );
      } else if (line.trim().isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              line,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
                height: 1.35,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Suggested Prompts Chips Bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: AppColors.surfaceContainerLowest,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestedPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    label: Text(
                      prompt,
                      style: AppTypography.labelSmall.copyWith(fontSize: 11, color: AppColors.primary),
                    ),
                    onPressed: () => _sendMessage(prompt),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const Divider(height: 1, color: AppColors.outlineVariant),

        // Messages Area
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isLoading) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Text('K2i AI is analyzing financial context...', style: AppTypography.labelSmall),
                      ],
                    ),
                  ),
                );
              }

              final msg = _messages[index];
              return Align(
                alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: msg.isUser ? AppColors.primary : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: msg.isUser ? null : Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.psychology, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'K2i Financial AI',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      if (!msg.isUser) const SizedBox(height: 6),
                      _buildFormattedText(msg.text, msg.isUser),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Input Field Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border(top: BorderSide(color: AppColors.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Ask K2i AI about your spending, budget, rules...',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (val) => _sendMessage(val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => _sendMessage(_inputController.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper Modal Launcher for App-Wide Integrated K2i Chatbot
class K2iChatbotBottomSheet {
  static void show(BuildContext context, {String? initialQuery}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              toolbarHeight: 56,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              leading: const Padding(
                padding: EdgeInsets.all(12),
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.psychology_outlined, color: Colors.white, size: 18),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('K2i Financial AI Chatbot', style: AppTypography.headlineMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Integrated Money & Savings Buddy', style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            body: K2iChatbotWidget(initialQuery: initialQuery),
          ),
        );
      },
    );
  }
}
