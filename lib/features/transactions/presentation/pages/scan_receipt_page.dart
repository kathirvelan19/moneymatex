import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/web_ocr_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_chip.dart';
import '../../../ai/domain/models/receipt_data.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';

/// Professional AI Receipt Scanner Screen matching Gemini Vision methodology & UI specification
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
  String _loadingStepText = 'Analyzing with Gemini AI...';

  ReceiptData? _extractedReceipt;
  List<ReceiptItem> _extractedItems = [];

  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _subtotalController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();

  String _selectedCategory = 'Travel';
  String _selectedPaymentMethod = 'UPI';

  final List<String> _categories = [
    'Travel',
    'Food & Dining',
    'Shopping',
    'Bills & Utilities',
    'Transport',
    'Entertainment',
    'Health & Wellness',
    'Housing & Rent',
    'Other'
  ];

  bool _isItemsExpanded = false;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _taxController.dispose();
    _subtotalController.dispose();
    _discountController.dispose();
    _receiptNoController.dispose();
    super.dispose();
  }

  /// Step 2: Send receipt image to Spring Boot backend for Gemini-powered extraction.
  /// The backend owns the Gemini API key — Flutter never calls Gemini directly.
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
      _loadingStepText = 'Analyzing with AI...';
    });

    try {
      final backendOcr = ref.read(backendOcrServiceProvider);
      final receipt = await backendOcr.parseReceiptViaBackend(_selectedImageDataUrl!);

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _hasScanned = true;
          _extractedReceipt = receipt;

          if (receipt.isSuccess) {
            _merchantController.text = receipt.merchantName ?? '';
            _amountController.text = receipt.totalAmount != null
                ? (receipt.totalAmount! % 1 == 0
                    ? receipt.totalAmount!.toInt().toString()
                    : receipt.totalAmount!.toStringAsFixed(2))
                : '';

            final now = DateTime.now();
            final dateStr = receipt.dateString ??
                (receipt.date != null
                    ? '${receipt.date!.day.toString().padLeft(2, '0')}-${receipt.date!.month.toString().padLeft(2, '0')}-${receipt.date!.year}'
                    : '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}');
            _dateController.text = dateStr;

            if (receipt.suggestedCategory.isNotEmpty && _categories.contains(receipt.suggestedCategory)) {
              _selectedCategory = receipt.suggestedCategory;
            } else if (receipt.suggestedCategory == 'Transport') {
              _selectedCategory = 'Travel';
            } else {
              _selectedCategory = 'Travel';
            }

            _selectedPaymentMethod = receipt.paymentMethod ?? 'UPI';
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

      // Auto trigger analysis
      _processReceiptWithGemini();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'We couldn\'t process this image. Please try another receipt.';
        });
      }
    }
  }


  /// Date Picker Dialog Handler
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C38FF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  /// Step 3: Confirm and save expense into transactions repository
  void _confirmTransaction() {
    final amountText = _amountController.text.trim();
    final merchantText = _merchantController.text.trim();
    final dateText = _dateController.text.trim();

    final parsedAmount = double.tryParse(amountText.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid expense total amount.')),
      );
      return;
    }

    final merchantName = merchantText.isNotEmpty ? merchantText : 'Receipt Expense';
    final categoryName = _selectedCategory;

    // Parse date safely
    DateTime parsedDate = DateTime.now();
    try {
      if (dateText.contains('-')) {
        final parts = dateText.split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD
            parsedDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else {
            // DD-MM-YYYY
            parsedDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      }
    } catch (_) {}

    final newItem = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: merchantName,
      category: categoryName,
      amount: parsedAmount,
      wallet: 'Main Account',
      paymentMethod: _selectedPaymentMethod,
      date: parsedDate,
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
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: Text(
          'Receipt Scanner',
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outer Professional Container Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEEF2F6), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Receipt AI Scanner
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF7C3AED),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Receipt AI Scanner',
                              style: AppTypography.headlineMedium.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Upload paper or digital receipts for auto-extraction',
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Mode Selector Chips
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

                  const SizedBox(height: 20),

                  // Upload Zone or Preview Card
                  if (_selectedImageDataUrl == null) ...[
                    // Dashed Upload Zone Box
                    InkWell(
                      onTap: () => _handleImageSelection(isCamera: false),
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: _DashedRectPainter(
                          color: const Color(0xFFCBD5E1),
                          strokeWidth: 1.5,
                          gap: 6.0,
                          radius: 16.0,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 170,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x08000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFF475569),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Click to upload or drag receipt image',
                                style: AppTypography.headlineMedium.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PNG, JPG, JPEG up to 5MB',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Image Preview Container Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Receipt Image Card Preview Frame
                          Container(
                            height: 200,
                            constraints: const BoxConstraints(maxWidth: 160),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              _selectedImageDataUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.receipt_long, size: 64, color: Color(0xFF7C3AED)),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Analyzing / Scan Button
                          if (_isProcessing) ...[
                            SizedBox(
                              width: 260,
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9361FF),
                                  disabledBackgroundColor: const Color(0xFF9361FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                ),
                                label: Text(
                                  _loadingStepText,
                                  style: AppTypography.headlineMedium.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: 280,
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: _processReceiptWithGemini,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C38FF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                                label: Text(
                                  'Scan & Extract Receipt Data',
                                  style: AppTypography.headlineMedium.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _handleImageSelection(isCamera: false),
                              icon: const Icon(Icons.refresh, size: 14, color: Color(0xFF64748B)),
                              label: Text(
                                'Change Image',
                                style: AppTypography.labelSmall.copyWith(color: const Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Extracted Details Form Section
                  if (_hasScanned && !_isProcessing) ...[
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),

                    // Extracted Details Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'EXTRACTED DETAILS',
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF6D28D9),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.labelSmall.copyWith(color: const Color(0xFF991B1B), fontWeight: FontWeight.w600),
                              ),
                            ),
                            TextButton(
                              onPressed: _processReceiptWithGemini,
                              child: const Text('Retry', style: TextStyle(color: Color(0xFF6C38FF), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 2-Column Responsive Form Layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isWide = constraints.maxWidth > 500;

                        final merchantField = _buildFormField(
                          label: 'MERCHANT',
                          child: _buildCustomTextField(
                            controller: _merchantController,
                            hint: 'Store, Restaurant or Vendor name',
                          ),
                        );

                        final amountField = _buildFormField(
                          label: 'AMOUNT (₹)',
                          child: _buildCustomTextField(
                            controller: _amountController,
                            hint: '0.00',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        );

                        final dateField = _buildFormField(
                          label: 'DATE',
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: _buildCustomTextField(
                              controller: _dateController,
                              hint: 'DD-MM-YYYY',
                              readOnly: true,
                              trailingIcon: Icons.calendar_today_outlined,
                              onTrailingTap: () => _selectDate(context),
                            ),
                          ),
                        );

                        final categoryField = _buildFormField(
                          label: 'CATEGORY',
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                items: _categories.map((String cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat,
                                    child: Text(cat),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedCategory = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        );

                        final taxField = _buildFormField(
                          label: 'TAX (OPTIONAL)',
                          child: _buildCustomTextField(
                            controller: _taxController,
                            hint: 'Optional tax amount',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        );

                        if (isWide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: merchantField),
                                  const SizedBox(width: 16),
                                  Expanded(child: amountField),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: dateField),
                                  const SizedBox(width: 16),
                                  Expanded(child: categoryField),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: taxField),
                                  const SizedBox(width: 16),
                                  const Expanded(child: SizedBox()),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              merchantField,
                              const SizedBox(height: 16),
                              amountField,
                              const SizedBox(height: 16),
                              dateField,
                              const SizedBox(height: 16),
                              categoryField,
                              const SizedBox(height: 16),
                              taxField,
                            ],
                          );
                        }
                      },
                    ),

                    if (_extractedItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: _isItemsExpanded,
                          onExpansionChanged: (exp) => setState(() => _isItemsExpanded = exp),
                          title: Text(
                            'Line Items (${_extractedItems.length})',
                            style: AppTypography.headlineMedium.copyWith(fontSize: 14, color: const Color(0xFF6C38FF)),
                          ),
                          children: _extractedItems.map((item) {
                            return ListTile(
                              dense: true,
                              title: Text(item.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                              subtitle: item.quantity != null ? Text('Qty: ${item.quantity}') : null,
                              trailing: Text(
                                '₹${(item.totalPrice ?? item.price ?? 0).toStringAsFixed(2)}',
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF6C38FF)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Confirm & Save Expense Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _confirmTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C38FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                          shadowColor: const Color(0x406C38FF),
                        ),
                        child: Text(
                          'Confirm & Save Expense',
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Security Note Footer
            Center(
              child: Text(
                'Security Note: AI Vision powered by Gemini. Receipts are parsed securely in-memory.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? trailingIcon,
    VoidCallback? onTrailingTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: AppTypography.bodyMedium.copyWith(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: trailingIcon != null
              ? IconButton(
                  icon: Icon(trailingIcon, size: 18, color: const Color(0xFF64748B)),
                  onPressed: onTrailingTap,
                )
              : null,
        ),
      ),
    );
  }
}

/// Custom Painter for Dashed Rectangle Border
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path metricsPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = distance + gap > metric.length ? metric.length - distance : gap;
        metricsPath.addPath(metric.extractPath(distance, distance + len / 2), Offset.zero);
        distance += len;
      }
    }

    canvas.drawPath(metricsPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) => false;
}
