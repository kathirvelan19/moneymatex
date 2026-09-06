/// Abstract interface for AI Providers (Isolated abstraction)
/// Can swap implementations (e.g. Gemini, OpenAI, Claude, Local LLM) without changing UI code.
abstract class AIProviderInterface {
  Future<String> generateAdvisoryResponse({
    required String prompt,
    Map<String, dynamic>? contextData,
  });

  Future<Map<String, dynamic>> calculateFinancialHealthScore({
    required Map<String, dynamic> financialMetrics,
  });

  Future<List<String>> generateActionPlan({
    required Map<String, dynamic> userGoal,
  });
}
