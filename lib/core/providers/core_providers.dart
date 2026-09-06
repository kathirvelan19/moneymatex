import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../services/ai/ai_provider_interface.dart';
import '../services/ai/ai_service.dart';
import '../services/ocr/ocr_engine_interface.dart';
import '../services/ocr/ocr_service.dart';
import '../services/payment_bank/payment_gateway_interface.dart';
import '../services/payment_bank/bank_sync_service.dart';

/// Provider for central Dio HTTP client
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Provider for isolated AI Service (Implements AIProviderInterface)
final aiServiceProvider = Provider<AIProviderInterface>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AIService(dioClient: dioClient);
});

/// Provider for isolated OCR Service (Implements OCREngineInterface)
final ocrServiceProvider = Provider<OCREngineInterface>((ref) {
  return OCRService();
});

/// Provider for isolated Bank/Payment Sync Service (Implements PaymentGatewayInterface)
final bankSyncServiceProvider = Provider<PaymentGatewayInterface>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BankSyncService(dioClient: dioClient);
});
