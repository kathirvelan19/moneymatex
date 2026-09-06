import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../data/services/gemini_service.dart';
import '../../domain/models/receipt_data.dart';
import '../../domain/models/scanned_upi.dart';

/// Central provider for Gemini AI Service
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

/// State container for Receipt Scanning Lifecycle
class ReceiptScanState {
  final bool isScanning;
  final ReceiptData? data;
  final String? imageDataUrl;
  final String? errorMessage;

  const ReceiptScanState({
    this.isScanning = false,
    this.data,
    this.imageDataUrl,
    this.errorMessage,
  });

  ReceiptScanState copyWith({
    bool? isScanning,
    ReceiptData? data,
    String? imageDataUrl,
    String? errorMessage,
  }) {
    return ReceiptScanState(
      isScanning: isScanning ?? this.isScanning,
      data: data ?? this.data,
      imageDataUrl: imageDataUrl ?? this.imageDataUrl,
      errorMessage: errorMessage,
    );
  }
}

class ReceiptScanNotifier extends StateNotifier<ReceiptScanState> {
  final GeminiService _geminiService;

  ReceiptScanNotifier(this._geminiService) : super(const ReceiptScanState());

  Future<void> scanReceipt(String imageDataUrl) async {
    state = state.copyWith(isScanning: true, imageDataUrl: imageDataUrl, errorMessage: null);

    try {
      final result = await _geminiService.parseReceipt(imageDataUrl);
      if (result.isSuccess) {
        state = state.copyWith(
          isScanning: false,
          data: result,
        );
      } else {
        state = state.copyWith(
          isScanning: false,
          errorMessage: result.errorMessage ?? 'Failed to scan receipt.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: 'Unable to scan this receipt. Please try again.',
      );
    }
  }

  void reset() {
    state = const ReceiptScanState();
  }
}

final receiptScanProvider = StateNotifierProvider<ReceiptScanNotifier, ReceiptScanState>((ref) {
  final service = ref.watch(geminiServiceProvider);
  return ReceiptScanNotifier(service);
});

/// State container for UPI Screenshot Scanning Lifecycle
class UpiScanState {
  final bool isScanning;
  final ScannedUPI? data;
  final String? imageDataUrl;
  final String? errorMessage;

  const UpiScanState({
    this.isScanning = false,
    this.data,
    this.imageDataUrl,
    this.errorMessage,
  });

  UpiScanState copyWith({
    bool? isScanning,
    ScannedUPI? data,
    String? imageDataUrl,
    String? errorMessage,
  }) {
    return UpiScanState(
      isScanning: isScanning ?? this.isScanning,
      data: data ?? this.data,
      imageDataUrl: imageDataUrl ?? this.imageDataUrl,
      errorMessage: errorMessage,
    );
  }
}

class UpiScanNotifier extends StateNotifier<UpiScanState> {
  final GeminiService _geminiService;

  UpiScanNotifier(this._geminiService) : super(const UpiScanState());

  Future<void> scanUpiScreenshot(String imageDataUrl) async {
    state = state.copyWith(isScanning: true, imageDataUrl: imageDataUrl, errorMessage: null);

    try {
      final result = await _geminiService.parseUpiScreenshot(imageDataUrl);
      if (result.isSuccess) {
        state = state.copyWith(
          isScanning: false,
          data: result,
        );
      } else {
        state = state.copyWith(
          isScanning: false,
          errorMessage: result.errorMessage ?? 'Failed to scan UPI screenshot.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: 'Unable to scan this UPI screenshot. Please try again.',
      );
    }
  }

  void reset() {
    state = const UpiScanState();
  }
}

final upiScanProvider = StateNotifierProvider<UpiScanNotifier, UpiScanState>((ref) {
  final service = ref.watch(geminiServiceProvider);
  return UpiScanNotifier(service);
});

/// FutureProvider for fetching Gemini AI Spending Insights based on current transactions
final spendingInsightsProvider = FutureProvider<List<String>>((ref) async {
  final transactions = ref.watch(transactionsProvider);
  final service = ref.watch(geminiServiceProvider);
  return service.getSpendingInsights(transactions);
});
