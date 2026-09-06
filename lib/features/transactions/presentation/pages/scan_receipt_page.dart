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
import '../../../ai/domain/models/receipt_data.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';

/// Multimodal Receipt Scanner Screen powered by Gemini 2.5 Flash AI
class ScanReceiptPage extends ConsumerStatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  ConsumerState<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends ConsumerState<ScanReceiptPage> {
  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _selectedImageDataUrl;
  String? _errorMessage;
  String _loadingStepText = 'Analyzing receipt...';

  ReceiptData? _extractedReceipt;
  List<ReceiptItem> _extractedItems = [];

  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _subtotalController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();

  bool _isItemsExpanded = false;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    _paymentMethodController.dispose();
    _taxController.dispose();
    _subtotalController.dispose();
    _discountController.dispose();
    _receiptNoController.dispose();
    super.dispose();
  }

  /// Step 1: Pick Image from Gallery or Camera
  Future<void> _handleImageSelection({bool isCamera = false}) async {
    try {
      final dataUrl = await WebOcrService.pickReceiptImage(isCamera: isCamera);

      if (dataUrl == null || dataUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a receipt image first.')),
          );
        }
        return;
      }

      setState(() {
        _selectedImageDataUrl = dataUrl;
        _hasScanned = false;
        _extractedReceipt = null;
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'We couldn\'t process this image. Please try another receipt.';
        });
      }
    }
  }

  /// Step 2: User taps "Scan Receipt" to trigger Gemini 2.5 Flash API
  Future<void> _processReceiptWithGemini() async {
    if (_selectedImageDataUrl == null || _selectedImageDataUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a receipt image first.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _loadingStepText = 'Analyzing receipt...';
    });

    // Step animation feedback
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _isProcessing) {
        setState(() => _loadingStepText = 'Extracting merchant & date...');
      }
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _isProcessing) {
        setState(() => _loadingStepText = 'Reading total amount & tax...');
      }
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _isProcessing) {
        setState(() => _loadingStepText = 'Detecting category with MoneyMateX AI...');
      }
    });

    try {
      final geminiService = ref.read(geminiServiceProvider);
      final receipt = await geminiService.parseReceipt(_selectedImageDataUrl!);

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _hasScanned = true;
          _extractedReceipt = receipt;

          if (receipt.isSuccess) {
            _merchantController.text = receipt.merchantName ?? '';
            _amountController.text = receipt.totalAmount != null ? receipt.totalAmount!.toStringAsFixed(2) : '';

            final now = DateTime.now();
            final dateStr = receipt.dateString ??
                (receipt.date != null
                    ? '${receipt.date!.year}-${receipt.date!.month.toString().padLeft(2, '0')}-${receipt.date!.day.toString().padLeft(2, '0')}'
                    : '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
            _dateController.text = dateStr;

            _categoryController.text = receipt.suggestedCategory;
            _paymentMethodController.text = receipt.paymentMethod ?? 'UPI';
            _taxController.text = receipt.taxAmount != null ? receipt.taxAmount!.toStringAsFixed(2) : '';
            _subtotalController.text = receipt.subtotal != null ? receipt.subtotal!.toStringAsFixed(2) : '';
            _discountController.text = receipt.discount != null ? receipt.discount!.toStringAsFixed(2) : '';
            _receiptNoController.text = receipt.receiptNumber ?? '';
            _extractedItems = receipt.items;
          } else {
            _errorMessage = receipt.errorMessage ?? 'We couldn\'t read the receipt details. Please review the image and try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Unable to analyze the receipt right now. Please try again.';
        });
      }
    }
  }

  /// Step 3: Confirm and save expense into transactions repository
  void _confirmTransaction() {
    final amountText = _amountController.text.trim();
    final merchantText = _merchantController.text.trim();
    final categoryText = _categoryController.text.trim();
    final dateText = _dateController.text.trim();
    final paymentMethodText = _paymentMethodController.text.trim();

    final parsedAmount = double.tryParse(amountText.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid expense total amount.')),
      );
      return;
    }

    final merchantName = merchantText.isNotEmpty ? merchantText : 'Receipt Expense';
    final categoryName = categoryText.isNotEmpty ? categoryText : 'Uncategorized';
    final paymentName = paymentMethodText.isNotEmpty ? paymentMethodText : 'UPI';

    final newItem = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: merchantName,
      category: categoryName,
      amount: parsedAmount,
      wallet: 'Main Account',
      paymentMethod: paymentName,
      date: DateTime.tryParse(dateText) ?? DateTime.now(),
      isExpense: true,
      icon: TransactionsNotifier.getCategoryIcon(categoryName),
      source: 'gemini_receipt_ocr',
      ocrConfidence: _extractedReceipt?.merchantName != null && _extractedReceipt?.totalAmount != null ? 0.98 : 0.70,
      items: _extractedItems.map((i) => '${i.name} (x${i.quantity ?? 1}) - ₹${i.totalPrice ?? i.price ?? 0}').toList(),
    );

    // Save to database / Riverpod transaction store
    ref.read(transactionsProvider.notifier).addTransaction(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ₹${parsedAmount.toStringAsFixed(2)} expense for $merchantName'),
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
          'Scan Receipt',
          style: AppTypography.headlineMedium.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Take a photo or choose an image. Gemini 2.5 Flash AI will automatically analyze your receipt and extract details.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.m),

            // Mode Selector
            Row(
              children: [
                MMCategoryChip(
                  label: 'Receipt Scanner',
                  isSelected: true,
                  onSelected: () {},
                ),
                const SizedBox(width: AppSpacing.s),
                MMCategoryChip(
                  label: 'UPI Screenshot Scanner',
                  isSelected: false,
                  onSelected: () => context.go(AppRoutes.scanUpi),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),

            // Receipt Viewfinder / Preview Container
            Container(
              height: 260,
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
                                const Icon(Icons.receipt_long, size: 64, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'Receipt Loaded',
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
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scan your receipt',
                          style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Take a photo or choose an image below',
                          style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),

                  // Target Box Border
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.8), width: 2),
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                  ),

                  if (_selectedImageDataUrl != null && _selectedImageDataUrl!.isNotEmpty && !_isProcessing && !_hasScanned)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Receipt Preview',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Polished Loading Overlay with step messages
                  if (_isProcessing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.88),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: AppColors.primary),
                            const SizedBox(height: AppSpacing.l),
                            Text(
                              _loadingStepText,
                              style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gemini 2.5 Flash AI Engine',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.l),

            // Action Buttons Row
            if (!_hasScanned) ...[
              if (_selectedImageDataUrl == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: MMButton(
                        label: 'Take Photo',
                        icon: Icons.camera_alt,
                        onPressed: () => _handleImageSelection(isCamera: true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: MMButton(
                        label: 'Choose from Gallery',
                        type: MMButtonType.secondary,
                        icon: Icons.photo_library,
                        onPressed: () => _handleImageSelection(isCamera: false),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: MMButton(
                        label: 'Retake',
                        type: MMButtonType.secondary,
                        icon: Icons.refresh,
                        onPressed: () => _handleImageSelection(isCamera: false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: MMButton(
                        label: 'Scan Receipt',
                        icon: Icons.auto_awesome,
                        onPressed: () {
                          if (!_isProcessing) {
                            _processReceiptWithGemini();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: MMButton(
                      label: 'Scan Another Receipt',
                      type: MMButtonType.secondary,
                      icon: Icons.add_a_photo,
                      onPressed: () {
                        setState(() {
                          _selectedImageDataUrl = null;
                          _hasScanned = false;
                          _extractedReceipt = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],

            // Extracted Receipt Information Review Section
            if (_hasScanned && !_isProcessing) ...[
              const SizedBox(height: AppSpacing.stackLg),
              const Divider(color: AppColors.outlineVariant),
              const SizedBox(height: AppSpacing.m),

              Row(
                children: [
                  Text(
                    'Receipt Details',
                    style: AppTypography.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_extractedReceipt != null && _extractedReceipt!.isSuccess)
                    const MMStatusChip(
                      label: 'Gemini 2.5 AI Verified',
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
                label: 'Merchant',
                hint: 'e.g. Reliance Fresh, Swiggy, Store',
                controller: _merchantController,
              ),

              const SizedBox(height: AppSpacing.m),

              MMTextField(
                label: 'Amount (₹)',
                hint: '450.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _amountController,
              ),

              const SizedBox(height: AppSpacing.m),

              MMTextField(
                label: 'Date',
                hint: 'YYYY-MM-DD (e.g. 2026-08-20)',
                controller: _dateController,
              ),

              const SizedBox(height: AppSpacing.m),

              MMTextField(
                label: 'Tax (₹)',
                hint: '21.43 (Optional)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _taxController,
              ),

              const SizedBox(height: AppSpacing.m),

              MMTextField(
                label: 'Category',
                hint: 'Food & Dining, Transport, Groceries, Shopping, etc.',
                controller: _categoryController,
              ),

              const SizedBox(height: AppSpacing.m),

              Row(
                children: [
                  Expanded(
                    child: MMTextField(
                      label: 'Subtotal (₹)',
                      hint: 'Optional',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: _subtotalController,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: MMTextField(
                      label: 'Discount (₹)',
                      hint: 'Optional',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: _discountController,
                    ),
                  ),
                ],
              ),

              if (_extractedItems.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: _isItemsExpanded,
                    onExpansionChanged: (exp) => setState(() => _isItemsExpanded = exp),
                    title: Text(
                      'Line Items (${_extractedItems.length})',
                      style: AppTypography.headlineMedium.copyWith(fontSize: 14, color: AppColors.primary),
                    ),
                    children: _extractedItems.map((item) {
                      return ListTile(
                        dense: true,
                        title: Text(item.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: item.quantity != null ? Text('Qty: ${item.quantity}') : null,
                        trailing: Text(
                          '₹${(item.totalPrice ?? item.price ?? 0).toStringAsFixed(2)}',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.stackLg),

              Text(
                'Please review details before confirming.',
                style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
              ),

              const SizedBox(height: AppSpacing.m),

              MMButton(
                label: 'Confirm & Add Expense',
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
