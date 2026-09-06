import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Environment Configuration Manager
abstract class EnvConfig {
  /// Load environment variables from .env file gracefully
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // If .env file is missing or not packaged in assets, fallback safely
    }
  }

  /// Returns GEMINI_API_KEY safely without throwing NotInitializedError
  static String get geminiApiKey {
    try {
      if (dotenv.isInitialized) {
        final key = dotenv.env['GEMINI_API_KEY'];
        if (key != null && key.trim().isNotEmpty) {
          return key.trim();
        }
      }
    } catch (_) {}

    return const String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    ).trim();
  }
}
