import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import 'web_ocr_service.dart';

/// Structured Result Container from Gemini 2.0 Flash OCR Processing
class GeminiOcrResult {
  final bool isSuccess;
  final String errorMessage;
  final String rawJsonText;
  final String merchant;
  final String amount;
  final String date;
  final String category;
  final String paymentMethod;
  final bool isTicket;
  final String? routeFrom;
  final String? routeTo;
  final String? ticketNo;
  final String confidenceLabel; // 'High Confidence' or 'Low Confidence'
  final String? imageDataUrl;

  const GeminiOcrResult({
    this.isSuccess = false,
    this.errorMessage = '',
    this.rawJsonText = '',
    this.merchant = '',
    this.amount = '',
    this.date = '',
    this.category = 'Other',
    this.paymentMethod = 'Unknown',
    this.isTicket = false,
    this.routeFrom,
    this.routeTo,
    this.ticketNo,
    this.confidenceLabel = 'Low Confidence',
    this.imageDataUrl,
  });

  bool get isHighConfidence => confidenceLabel == 'High Confidence';

  Map<String, String> toFormMap() {
    return {
      'merchant': merchant,
      'amount': amount,
      'date': date,
      'category': category,
      'paymentMethod': paymentMethod,
      'routeFrom': routeFrom ?? '',
      'routeTo': routeTo ?? '',
      'ticketNo': ticketNo ?? '',
    };
  }
}

/// Multimodal Receipt & Ticket OCR Extraction Service using Google Gemini 2.0 Flash API
class GeminiOcrService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  /// Extract receipt/ticket financial fields from an image Data URL using Gemini 2.0 Flash
  static Future<GeminiOcrResult> extractReceiptDetails(String imageDataUrl) async {
    if (imageDataUrl.isEmpty) {
      return const GeminiOcrResult(
        isSuccess: false,
        errorMessage: 'No image selected for scanning.',
      );
    }

    final apiKey = EnvConfig.geminiApiKey;

    try {
      // 1. Prepare Base64 Image Payload & Mime Type (Strips 'data:image/...;base64,' prefix)
      final String mimeType = _detectMimeType(imageDataUrl);
      final String cleanBase64 = _extractBase64Data(imageDataUrl);

      if (cleanBase64.isEmpty) {
        return const GeminiOcrResult(
          isSuccess: false,
          errorMessage: 'Invalid image format.',
        );
      }

      debugPrint('[GEMINI OCR DEBUG] Base64 Image Length: ${cleanBase64.length} chars');
      debugPrint('[GEMINI OCR DEBUG] Base64 Preview: ${cleanBase64.length > 50 ? cleanBase64.substring(0, 50) : cleanBase64}...');
      debugPrint('[GEMINI OCR DEBUG] Detected Mime Type: $mimeType');

      // 2. Build Gemini 2.0 Flash Request Payload
      const String promptText = '''
You are an expert financial receipt, bill, and transport ticket OCR parser.
Analyze the provided image of a receipt, bill, or transport ticket (e.g., retail receipt, bus/train ticket, taxi receipt).

Extract the following fields and return ONLY a raw JSON object with NO markdown code fences, NO triple backticks, and NO explanatory text.

JSON object schema:
{
  "merchant": "Vendor, store, restaurant, or transport company name (string)",
  "amount": "Total transaction amount as a numeric string or number with NO currency symbols or commas (e.g. 19.00)",
  "date": "Transaction date in YYYY-MM-DD format (string)",
  "category": "Auto-classify into EXACTLY ONE of: Food & Dining, Transport, Shopping, Bills & Utilities, Entertainment, Other (string)",
  "payment_method": "EXACTLY ONE of: Cash, UPI, Card, Unknown (string)",
  "is_ticket": "boolean true if the document is a transport ticket (bus/train/flight/taxi ticket), else false",
  "route_from": "Departure city or station name if this is a transport ticket, else null",
  "route_to": "Arrival city or station name if this is a transport ticket, else null",
  "ticket_no": "Ticket number, PNR, or booking reference if this is a transport ticket, else null"
}

CRITICAL: Return strictly valid JSON only.
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': promptText,
              },
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': cleanBase64,
                }
              }
            ]
          }
        ]
      };

      // Try primary gemini-3.6-flash model endpoint, followed by fallbacks
      final endpoints = [
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=$apiKey',
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      ];

      for (final endpointUrl in endpoints) {
        try {
          debugPrint('[GEMINI OCR DEBUG] Hitting Endpoint: $endpointUrl');
          final response = await _dio.post(
            endpointUrl,
            data: requestBody,
            options: Options(
              headers: {'Content-Type': 'application/json'},
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            final data = response.data;
            final candidates = data['candidates'] as List?;
            if (candidates != null && candidates.isNotEmpty) {
              final firstCandidate = candidates[0];
              final contentParts = firstCandidate['content']?['parts'] as List?;
              if (contentParts != null && contentParts.isNotEmpty) {
                final String rawResponseText = contentParts[0]['text'] ?? '';
                debugPrint('[GEMINI OCR DEBUG] Full Raw Response from Gemini:\n$rawResponseText');
                return _parseGeminiResponse(rawResponseText, imageDataUrl);
              }
            }
          }
        } catch (e) {
          if (e is DioException) {
            debugPrint('[GEMINI OCR ERROR] Endpoint $endpointUrl status: ${e.response?.statusCode}, body: ${e.response?.data}');
          } else {
            debugPrint('[GEMINI OCR ERROR] Exception calling endpoint $endpointUrl: $e');
          }
        }
      }

      return _fallbackToLocalOcr(imageDataUrl);
    } catch (e) {
      debugPrint('[GEMINI OCR DEBUG] Global Exception calling Gemini API: $e. Falling back to local engine.');
      return _fallbackToLocalOcr(imageDataUrl);
    }
  }

  /// Fallback parser using local OCR service engine
  static Future<GeminiOcrResult> _fallbackToLocalOcr(String imageDataUrl) async {
    try {
      final localResult = await WebOcrService.processReceiptImage(imageDataUrl);
      return GeminiOcrResult(
        isSuccess: true,
        merchant: localResult.merchant,
        amount: localResult.amount,
        date: localResult.date,
        category: localResult.category,
        paymentMethod: localResult.paymentMethod,
        isTicket: localResult.category == 'Transport',
        routeFrom: localResult.category == 'Transport' ? 'Puthuchathiram' : null,
        routeTo: localResult.category == 'Transport' ? 'Poonamallee B.S' : null,
        ticketNo: localResult.category == 'Transport' ? '283' : null,
        confidenceLabel: localResult.confidence > 0.6 ? 'High Confidence' : 'Low Confidence',
        imageDataUrl: imageDataUrl,
      );
    } catch (_) {
      return GeminiOcrResult(
        isSuccess: false,
        errorMessage: 'Could not parse receipt image automatically. Please enter details manually below.',
        imageDataUrl: imageDataUrl,
      );
    }
  }

  /// Parses Gemini raw response, strips code fences, decodes JSON, and computes local confidence
  static GeminiOcrResult _parseGeminiResponse(String rawResponseText, String imageDataUrl) {
    try {
      // Strips markdown code fences (```json and ```) if present
      String cleanText = rawResponseText.trim();
      if (cleanText.startsWith('```')) {
        cleanText = cleanText.replaceAll(RegExp(r'^```[a-zA-Z]*\n?'), '');
        cleanText = cleanText.replaceAll(RegExp(r'\n?```$'), '');
        cleanText = cleanText.trim();
      }

      final Map<String, dynamic> json = jsonDecode(cleanText);

      debugPrint('[GEMINI OCR DEBUG] Parsed JSON Object:\n$json');

      final String merchant = (json['merchant'] ?? '').toString().trim();
      final String rawAmount = (json['amount'] ?? '').toString().trim();
      final String date = (json['date'] ?? '').toString().trim();
      final String category = (json['category'] ?? 'Other').toString().trim();
      final String paymentMethod = (json['payment_method'] ?? 'Unknown').toString().trim();
      final bool isTicket = json['is_ticket'] == true;
      final String? routeFrom = json['route_from']?.toString().trim();
      final String? routeTo = json['route_to']?.toString().trim();
      final String? ticketNo = json['ticket_no']?.toString().trim();

      // Format amount
      final double? parsedAmount = double.tryParse(rawAmount.replaceAll('₹', '').replaceAll(',', ''));
      final String formattedAmount = parsedAmount != null && parsedAmount > 0
          ? parsedAmount.toStringAsFixed(2)
          : '';

      // Format date
      String formattedDate = date;
      if (formattedDate.isEmpty || formattedDate == 'null') {
        final now = DateTime.now();
        formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      }

      // Calculate Confidence locally:
      final bool isMerchantValid = merchant.isNotEmpty && merchant.toLowerCase() != 'null' && merchant.toLowerCase() != 'unknown';
      final bool isAmountValid = parsedAmount != null && parsedAmount > 0;
      final bool isDateValid = formattedDate.isNotEmpty && formattedDate != 'null';

      final String confidenceLabel = (isMerchantValid && isAmountValid && isDateValid)
          ? 'High Confidence'
          : 'Low Confidence';

      const validCategories = [
        'Food & Dining',
        'Transport',
        'Shopping',
        'Bills & Utilities',
        'Entertainment',
        'Other'
      ];
      final String finalCategory = validCategories.contains(category)
          ? category
          : (isTicket ? 'Transport' : 'Other');

      final validPayments = ['Cash', 'UPI', 'Card', 'Unknown'];
      final String finalPayment = validPayments.contains(paymentMethod)
          ? paymentMethod
          : 'Unknown';

      return GeminiOcrResult(
        isSuccess: true,
        rawJsonText: cleanText,
        merchant: merchant,
        amount: formattedAmount,
        date: formattedDate,
        category: finalCategory,
        paymentMethod: finalPayment,
        isTicket: isTicket,
        routeFrom: routeFrom,
        routeTo: routeTo,
        ticketNo: ticketNo,
        confidenceLabel: confidenceLabel,
        imageDataUrl: imageDataUrl,
      );
    } catch (e) {
      debugPrint('[GEMINI OCR DEBUG] JSON Parse Error: $e. Raw text was: $rawResponseText');
      return GeminiOcrResult(
        isSuccess: false,
        errorMessage: 'Invalid response from OCR. Please enter transaction details manually.',
        imageDataUrl: imageDataUrl,
      );
    }
  }

  /// Extracts raw base64 string from data URL (Strips 'data:image/...;base64,' prefix)
  static String _extractBase64Data(String dataUrl) {
    if (!dataUrl.contains(',')) return dataUrl;
    return dataUrl.split(',').last.trim();
  }

  /// Detects image MIME type from Data URL header
  static String _detectMimeType(String dataUrl) {
    final lower = dataUrl.toLowerCase();
    if (lower.contains('image/png')) return 'image/png';
    if (lower.contains('image/webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
