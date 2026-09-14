abstract class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://moneymatex-backend.onrender.com/api/v1',
  );

  // Auth Status
  static const String authStatus = '/auth/status';

  // Transactions & Wallets
  static const String transactions = '/transactions';
  static const String wallets = '/wallets';

  // Budgets & Goals
  static const String budgets = '/budgets';
  static const String goals = '/goals';

  // Bills & Subscriptions
  static const String bills = '/bills';
  static const String subscriptions = '/subscriptions';

  // AI Assistant Engine
  static const String aiChat = '/ai/chat';
  static const String aiHealthScore = '/ai/health-score';

  // OCR
  static const String ocrScan = '/ocr/scan-receipt';
}
