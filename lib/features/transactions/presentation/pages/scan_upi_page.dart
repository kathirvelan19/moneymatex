import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/web_ocr_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_button.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../../core/widgets/mm_text_field.dart';
import '../../../ai/domain/models/scanned_upi.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';

/// Multimodal UPI Screenshot Scanner Screen powered by Gemini 2.5 Flash AI
class ScanUpiPage extends ConsumerStatefulWidget {
  const ScanUpiPage({super.key});

  @override
  ConsumerState<ScanUpiPage> createState() => _ScanUpiPageState();
}

class _ScanUpiPageState extends ConsumerState<ScanUpiPage> {
  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _selectedImageDataUrl;
  String? _errorMessage;

  ScannedUPI? _scannedUpi;

  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _txIdController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _dateTimeController.dispose();
    _txIdController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelection({bool isCamera = false}) async {
    try {
      final dataUrl = await WebOcrService.pickReceiptImage(isCamera: isCamera);

      if (dataUrl == null || dataUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No UPI screenshot selected.')),
          );
        }
        return;
      }

      setState(() {
        _isProcessing = true;
        _hasScanned = true;
        _selectedImageDataUrl = dataUrl;
        _errorMessage = null;
      });

      // Call Gemini 2.5 Flash parseUpiScreenshot via GeminiService
      final geminiService = ref.read(geminiServiceProvider);
      final upi = await geminiService.parseUpiScreenshot(dataUrl);

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _scannedUpi = upi;

          if (upi.isSuccess) {
            _receiverController.text = upi.receiverName ?? '';
            _amountController.text = upi.paidAmount != null ? upi.paidAmount!.toStringAsFixed(2) : '';

            final now = DateTime.now();
            final dateStr = upi.dateTimeString ??
                (upi.dateTime != null
                    ? '${upi.dateTime!.year}-${upi.dateTime!.month.toString().padLeft(2, '0')}-${upi.dateTime!.day.toString().padLeft(2, '0')}'
                    : '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
            _dateTimeController.text = dateStr;

            _txIdController.text = upi.transactionId ?? '';
            _categoryController.text = upi.suggestedCategory;
          } else {
            _errorMessage = upi.errorMessage ?? 'Could not extract UPI screenshot details.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Error processing UPI screenshot: $e';
        });
      }
    }
  }

  void _confirmTransaction() {
    final amountText = _amountController.text.trim();
    final receiverText = _receiverController.text.trim();
    final categoryText = _categoryController.text.trim();
    final dateText = _dateTimeController.text.trim();
    final txIdText = _txIdController.text.trim();

    final parsedAmount = double.tryParse(amountText.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payment amount.')),
      );
      return;
    }

    final receiverName = receiverText.isNotEmpty ? receiverText : 'UPI Payment';
    final categoryName = categoryText.isNotEmpty ? categoryText : 'Uncategorized';

    final newItem = TransactionItem(
      id: txIdText.isNotEmpty ? txIdText : DateTime.now().millisecondsSinceEpoch.toString(),
      title: receiverName,
      category: categoryName,
      amount: parsedAmount,
      wallet: 'UPI Account',
      paymentMethod: 'UPI',
      date: DateTime.tryParse(dateText) ?? DateTime.now(),
      isExpense: true,
      icon: TransactionsNotifier.getCategoryIcon(categoryName),
      notes: txIdText.isNotEmpty ? 'UPI Ref: $txIdText' : 'Scanned via Gemini UPI Scanner',
      source: 'gemini_upi_ocr',
      ocrConfidence: _scannedUpi?.paidAmount != null && _scannedUpi?.receiverName != null ? 0.98 : 0.70,
    );

    // Add to Riverpod transaction store
    ref.read(transactionsProvider.notifier).addTransaction(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ₹${parsedAmount.toStringAsFixed(2)} UPI transaction to $receiverName'),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
      ),
    );

    context.go(AppRoutes.transactions);
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
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: Text(
          'UPI Screenshot Scanner',
          style: AppTypography.headlineMedium.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload a screenshot of GPay, PhonePe, Paytm, or BHIM UPI payments. Gemini 2.5 Flash will parse amount, payee, and transaction reference.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.m),

            // Scanner Mode Selector
            Row(
              children: [
                MMCategoryChip(
                  label: 'Receipt Scanner',
                  isSelected: false,
                  onSelected: () => context.go(AppRoutes.scanReceipt),
                ),
                const SizedBox(width: AppSpacing.s),
                MMCategoryChip(
                  label: 'UPI Screenshot Scanner',
                  isSelected: true,
                  onSelected: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),

            // Screenshot Preview Container
            InkWell(
              onTap: () => _handleImageSelection(isCamera: false),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Container(
                height: 240,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_selectedImageDataUrl != null && _selectedImageDataUrl!.isNotEmpty)
                      Positioned.fill(
                        child: Image.network(
                          _selectedImageDataUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.phone_android, size: 64, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Screenshot Loaded',
                                    style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to select UPI screenshot image',
                            style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),

                    // Framing Border
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.8), width: 2),
                        borderRadius: BorderRadius.circular(AppRadius.m),
                      ),
                    ),

                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          _hasScanned ? 'Tap to select another screenshot' : 'Select payment screenshot',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white),
                        ),
                      ),
                    ),

                    if (_isProcessing)
                      Container(
                        color: Colors.black.withValues(alpha: 0.85),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: AppSpacing.m),
                              Text(
                                'Extracting UPI Data with Gemini 2.5 Flash...',
                                style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // Select Screenshot Buttons
            Row(
              children: [
                Expanded(
                  child: MMButton(
                    label: 'Select Screenshot',
                    icon: Icons.photo_library,
                    onPressed: () => _handleImageSelection(isCamera: false),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: MMButton(
                    label: 'Take Photo',
                    type: MMButtonType.secondary,
                    icon: Icons.camera_alt,
                    onPressed: () => _handleImageSelection(isCamera: true),
                  ),
                ),
              ],
            ),

            // Extracted UPI Details Form
            if (_hasScanned && !_isProcessing) ...[
              const SizedBox(height: AppSpacing.stackLg),
              const Divider(color: AppColors.outlineVariant),
              const SizedBox(height: AppSpacing.m),

              Row(
                children: [
                  Text(
                    'Review Extracted UPI Payment',
                    style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_scannedUpi != null && _scannedUpi!.isSuccess)
                    const MMStatusChip(
                      label: 'Verified UPI',
                      backgroundColor: Color(0xFFDCFCE7),
                      textColor: Color(0xFF15803D),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.m),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(color: AppColors.tertiaryContainer),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.onTertiaryContainer, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.onTertiaryContainer, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              MMTextField(
                label: 'Receiver / Merchant Name',
                hint: 'e.g. Swiggy Pay, Store Name, Person Name',
                controller: _receiverController,
              ),

              const SizedBox(height: AppSpacing.m),

              MMTextField(
                label: 'Paid Amount (₹)',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _amountController,
              ),

              const SizedBox(height: AppSpacing.m),

              MMTextField(
                label: 'Date & Time',
                hint: 'YYYY-MM-DD HH:MM',
                controller: _dateTimeController,
              ),

              const SizedBox(height: AppSpacing.m),

              MMTextField(
                label: 'Transaction / UTR Reference ID',
                hint: 'e.g. 324156789012',
                controller: _txIdController,
              ),

              const SizedBox(height: AppSpacing.m),

              MMTextField(
                label: 'Category',
                hint: 'Food & Dining, Transport, Shopping, etc.',
                controller: _categoryController,
              ),

              const SizedBox(height: AppSpacing.stackLg),

              Text(
                'Please verify payee and amount before confirming.',
                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
              ),

              const SizedBox(height: AppSpacing.m),

              MMButton(
                label: 'Confirm & Add Transaction',
                onPressed: _confirmTransaction,
              ),
            ],
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
