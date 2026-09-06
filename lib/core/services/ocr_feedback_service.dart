import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single Correction Log Entry
class OcrCorrectionLog {
  final String id;
  final DateTime timestamp;
  final Map<String, String> original;
  final Map<String, String> corrected;
  final Map<String, String> diffs;

  const OcrCorrectionLog({
    required this.id,
    required this.timestamp,
    required this.original,
    required this.corrected,
    required this.diffs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'original': original,
        'corrected': corrected,
        'diffs': diffs,
      };

  factory OcrCorrectionLog.fromJson(Map<String, dynamic> json) =>
      OcrCorrectionLog(
        id: json['id'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        original: Map<String, String>.from(json['original'] ?? {}),
        corrected: Map<String, String>.from(json['corrected'] ?? {}),
        diffs: Map<String, String>.from(json['diffs'] ?? {}),
      );
}

/// Service managing Feedback Loop for tracking OCR corrections and accuracy evaluation
class OcrFeedbackService {
  static const String _storageKey = 'monematex_ocr_feedback_logs';

  /// Evaluates differences between original extraction and user-confirmed values, logging corrections
  static Future<void> evaluateAndLogCorrection({
    required Map<String, String> original,
    required Map<String, String> corrected,
  }) async {
    final Map<String, String> diffs = {};

    corrected.forEach((key, newVal) {
      final oldVal = original[key] ?? '';
      if (oldVal.trim() != newVal.trim()) {
        diffs[key] = 'Original: "$oldVal" -> Corrected: "$newVal"';
      }
    });

    if (diffs.isEmpty) {
      debugPrint('[OCR FEEDBACK LOOP] No field edits detected. High original extraction accuracy.');
      return;
    }

    final entry = OcrCorrectionLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      original: original,
      corrected: corrected,
      diffs: diffs,
    );

    debugPrint('[OCR FEEDBACK LOOP] Logged field corrections: ${entry.diffs}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getStringList(_storageKey) ?? [];
      existingJson.add(jsonEncode(entry.toJson()));
      await prefs.setStringList(_storageKey, existingJson);
    } catch (e) {
      debugPrint('[OCR FEEDBACK LOOP] Error saving feedback log: $e');
    }
  }

  /// Retrieves all logged feedback entries for accuracy analysis
  static Future<List<OcrCorrectionLog>> getCorrectionLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey) ?? [];
      return list
          .map((item) => OcrCorrectionLog.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
