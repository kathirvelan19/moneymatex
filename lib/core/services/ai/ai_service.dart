import 'ai_provider_interface.dart';
import '../../network/dio_client.dart';
import '../../constants/api_endpoints.dart';
import '../../../features/ai/data/services/gemini_service.dart';

/// Central AI Service manager implementing isolated AIProviderInterface
class AIService implements AIProviderInterface {
  final DioClient dioClient;
  final GeminiService _geminiService;

  AIService({required this.dioClient, GeminiService? geminiService})
      : _geminiService = geminiService ?? GeminiService();

  @override
  Future<String> generateAdvisoryResponse({
    required String prompt,
    Map<String, dynamic>? contextData,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.aiChat,
        data: {'prompt': prompt},
      );

      if (response.statusCode == 200 && response.data != null) {
        final text = response.data['response'];
        if (text != null && text.toString().isNotEmpty) {
          return text.toString();
        }
      }
    } catch (_) {
      // Fallback to Gemini 2.5 Flash / K2i Intelligent AI Engine seamlessly
    }

    return await _geminiService.generateChatResponse(
      prompt: prompt,
      contextData: contextData,
    );
  }

  @override
  Future<Map<String, dynamic>> calculateFinancialHealthScore({
    required Map<String, dynamic> financialMetrics,
  }) async {
    try {
      final response = await dioClient.post(ApiEndpoints.aiHealthScore);
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'healthScore': 0};
    } catch (e) {
      return {'healthScore': 0};
    }
  }

  @override
  Future<List<String>> generateActionPlan({
    required Map<String, dynamic> userGoal,
  }) async {
    return [
      'Set aside a fixed percentage of income monthly.',
      'Track category spending daily.',
      'Review net cash flow weekly.'
    ];
  }
}
