import 'payment_gateway_interface.dart';
import '../../network/dio_client.dart';

/// Service implementing PaymentGatewayInterface for bank syncing & UPI
class BankSyncService implements PaymentGatewayInterface {
  final DioClient dioClient;

  BankSyncService({required this.dioClient});

  @override
  Future<List<Map<String, dynamic>>> syncBankAccounts({required String bankId}) async {
    throw UnimplementedError('BankSyncService.syncBankAccounts is an infrastructure boundary for future implementation.');
  }

  @override
  Future<bool> initiatePayment({
    required double amount,
    required String recipient,
  }) async {
    throw UnimplementedError('BankSyncService.initiatePayment is an infrastructure boundary for future implementation.');
  }
}
