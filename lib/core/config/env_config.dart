import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Environment Configuration Manager
abstract class EnvConfig {
  static const String _prefsKey = 'custom_gemini_api_key';
  static const String _defaultFallbackKey = 'AIzaSyAv5RBcwYRaFeOAZhYQkJBJ4G2PhZaZ_WI';
  static String _userCustomKey = '';

  /// Load environment variables from .env file and SharedPreferences gracefully
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

  /// Save user provided Gemini API Key to SharedPreferences
  static Future<void> saveGeminiApiKey(String newKey) async {
    _userCustomKey = newKey.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _userCustomKey);
    } catch (e) {
      debugPrint('[EnvConfig] Could not save API key to SharedPreferences: $e');
    }
  }

  /// Check if a valid Gemini API key is configured
  static bool get isGeminiApiKeyConfigured => geminiApiKey.isNotEmpty;

  /// Returns true whenever a Gemini API key is present
  static bool get hasValidCustomGeminiApiKey {
    final key = geminiApiKey;
    return key.isNotEmpty;
  }

  /// Returns GEMINI_API_KEY safely without throwing NotInitializedError
  static String get geminiApiKey {
    if (_userCustomKey.isNotEmpty) {
      return _userCustomKey;
    }

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

    final envDefineKey = const String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    ).trim();

    if (envDefineKey.isNotEmpty && !envDefineKey.contains('your_gemini_api_key_here')) {
      return envDefineKey;
    }

    return _defaultFallbackKey;
  }
}


