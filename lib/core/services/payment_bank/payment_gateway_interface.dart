/// Isolated abstraction interface for Payment Gateways & UPI Aggregators
abstract class PaymentGatewayInterface {
  Future<bool> initiatePayment({
    required double amount,
    required String recipient,
  });

  Future<List<Map<String, dynamic>>> syncBankAccounts({
    required String bankId,
  });
}
