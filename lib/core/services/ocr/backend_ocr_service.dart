import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../constants/api_endpoints.dart';
import '../../network/dio_client.dart';
import '../../../features/ai/domain/models/receipt_data.dart';
import '../../../features/ai/data/services/gemini_service.dart';

/// BackendOcrService — Routes receipt scanning through the Spring Boot backend.
///
/// Architecture:
///   Flutter Web → Spring Boot (Render) → Gemini API → structured JSON → Flutter UI
///
/// Security contract:
///   - GEMINI_API_KEY never touches the Flutter app or browser.
///   - The browser only sends the image data URL to the secure backend.
///   - The backend owns all Gemini API communication.
class BackendOcrService {
  final DioClient _dioClient;

  BackendOcrService(this._dioClient);

  /// Sends the receipt image to the Spring Boot backend for Gemini-powered extraction.
  /// Falls back to client-side GeminiService if the backend is unreachable.
  Future<ReceiptData> parseReceiptViaBackend(String imageDataUrl) async {
    if (imageDataUrl.isEmpty) {
      return ReceiptData.error('No receipt image selected.');
    }

    try {
      debugPrint('[BACKEND OCR] Sending receipt to Spring Boot backend for extraction...');

      final response = await _dioClient.post(
        ApiEndpoints.ocrScan,
        data: {'imageDataUrl': imageDataUrl},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['isSuccess'] == true) {
          debugPrint('[BACKEND OCR] Success from Spring Boot backend.');

          final String merchant   = (data['merchant']        ?? '').toString();
          final String amountStr  = (data['amount']          ?? '0').toString();
          final String dateStr    = (data['date']            ?? '').toString();
          final String category   = (data['category']        ?? 'Other').toString();
          final String payment    = (data['payment_method']  ?? 'Unknown').toString();
          final String currency   = (data['currency']        ?? '₹').toString();

          final double totalAmount = double.tryParse(
            amountStr.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ?? 0.0;

          final DateTime? parsedDate = DateTime.tryParse(dateStr);

          final String detectedCategory =
              GeminiService.autoDetectCategory(merchant, gCategory: category);

          return ReceiptData(
            merchantName:      merchant.isNotEmpty ? merchant : 'Receipt Expense',
            date:              parsedDate ?? DateTime.now(),
            dateString:        dateStr,
            totalAmount:       totalAmount,
            currency:          currency,
            paymentMethod:     payment,
            suggestedCategory: detectedCategory,
            isSuccess:         true,
            imageDataUrl:      imageDataUrl,
          );
        } else {
          final errorMsg = data['errorMessage']?.toString() ?? 'Receipt extraction failed.';
          debugPrint('[BACKEND OCR] Backend returned isSuccess=false: $errorMsg');
          return ReceiptData.error(errorMsg);
        }
      }

      return ReceiptData.error('Unexpected response from receipt extraction service.');

    } on DioException catch (e) {
      debugPrint('[BACKEND OCR] Network error: ${e.type} — ${e.message}');

      // If backend is down/cold-starting on Render, return a clear error
      // Do NOT fall back to direct Gemini — the key is not available client-side
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return ReceiptData.error(
          'Receipt extraction service is starting up (Render cold start). '
          'Please wait 30 seconds and try again.',
        );
      }

      return ReceiptData.error(
        'Could not reach the receipt extraction service. Check your connection.',
      );

    } catch (e) {
      debugPrint('[BACKEND OCR] Unexpected error: $e');
      return ReceiptData.error('An unexpected error occurred during receipt scanning.');
    }
  }
}
