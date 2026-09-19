import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Environment Configuration Manager
///
/// Security contract:
///  - GEMINI_API_KEY is NEVER embedded in Flutter Web or Dart source.
///  - Gemini API calls are made exclusively by the Spring Boot backend.
///  - The Flutter app only needs API_BASE_URL to reach the backend.
///  - User-configurable keys (for direct Gemini AI chat features) are stored
///    in SharedPreferences and never committed to Git.
abstract class EnvConfig {
  static const String _prefsKey = 'custom_gemini_api_key';
  static String _userCustomKey = '';

  /// Load environment variables from .env file and SharedPreferences gracefully.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('[EnvConfig] Loaded .env asset successfully.');
    } catch (e) {
      debugPrint('[EnvConfig] Could not load .env asset: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _userCustomKey = prefs.getString(_prefsKey)?.trim() ?? '';
    } catch (e) {
      debugPrint('[EnvConfig] Could not read SharedPreferences: $e');
    }
  }

  /// Save user-provided Gemini API key to SharedPreferences.
  /// Used only for in-app AI chat/insights features that call Gemini client-side.
  /// Receipt scanning always goes through the Spring Boot backend — never uses this key.
  static Future<void> saveGeminiApiKey(String newKey) async {
    _userCustomKey = newKey.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _userCustomKey);
    } catch (e) {
      debugPrint('[EnvConfig] Could not save API key to SharedPreferences: $e');
    }
  }

  /// Whether the user has configured an in-app Gemini API key.
  static bool get isGeminiApiKeyConfigured => geminiApiKey.isNotEmpty;

  /// Returns true when a non-placeholder in-app Gemini key is present.
  static bool get hasValidCustomGeminiApiKey => geminiApiKey.isNotEmpty;

  /// Returns the in-app Gemini API key for client-side AI features (chat/insights).
  ///
  /// Priority order:
  ///  1. User-saved key (SharedPreferences)
  ///  2. .env file key (local dev only, NOT for production)
  ///
  /// IMPORTANT: This key is used only for AI chat/spending insights.
  /// Receipt OCR scanning routes through the Spring Boot backend — no key needed here.
  static String get geminiApiKey {
    // 1. User-saved key (highest priority)
    if (_userCustomKey.isNotEmpty) {
      return _userCustomKey;
    }

    // 2. .env file (local development only — never deployed to Vercel)
    try {
      if (dotenv.isInitialized) {
        final key = dotenv.env['GEMINI_API_KEY'];
        if (key != null &&
            key.trim().isNotEmpty &&
            !key.contains('your_gemini_api_key_here') &&
            !key.contains('your_key_here')) {
          return key.trim();
        }
      }
    } catch (_) {}

    // No key available — return empty. Features that need the key will prompt the user.
    return '';
  }
}
