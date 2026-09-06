import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth_onboarding/presentation/providers/auth_provider.dart';

class BillPaymentRecord {
  final String id;
  final String billId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String transactionId;

  const BillPaymentRecord({
    required this.id,
    required this.billId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
  });
}

class BillItem {
  final String id;
  final String name;
  final String category;
  final double amount;
  final String dueDate;
  final String frequency;
  final String paymentMethod;
  final String walletId;
  final bool isRecurring;
  final bool reminderEnabled;
  final String reminderTime;
  final String status; // "Upcoming", "Paid", "Overdue"
  final List<BillPaymentRecord> paymentHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BillItem({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.dueDate,
    required this.frequency,
    required this.paymentMethod,
    this.walletId = '',
    this.isRecurring = false,
    this.reminderEnabled = true,
    this.reminderTime = '09:00 AM',
    this.status = 'Upcoming',
    this.paymentHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  BillItem copyWith({
    String? id,
    String? name,
    String? category,
    double? amount,
    String? dueDate,
    String? frequency,
    String? paymentMethod,
    String? walletId,
    bool? isRecurring,
    bool? reminderEnabled,
    String? reminderTime,
    String? status,
    List<BillPaymentRecord>? paymentHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      frequency: frequency ?? this.frequency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      walletId: walletId ?? this.walletId,
      isRecurring: isRecurring ?? this.isRecurring,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BillsNotifier extends StateNotifier<List<BillItem>> {
  final DioClient _dioClient;
  final Ref _ref;

  BillsNotifier(this._dioClient, this._ref) : super([]) {
    _init();
  }

  void _init() {
    fetchBills();
    _ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.isAuthenticated) {
        fetchBills();
      } else {
        state = [];
      }
    });
  }

  Future<void> fetchBills() async {
    try {
      final res = await _dioClient.get(ApiEndpoints.bills);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data;
        final items = list.map((json) => BillItem(
          id: json['id'] ?? '',
          name: json['name'] ?? '',
          category: json['category'] ?? 'Utilities',
          amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
          dueDate: json['dueDate'] ?? '',
          frequency: json['frequency'] ?? 'Monthly',
          paymentMethod: json['paymentMethod'] ?? 'Wallet',
          walletId: json['walletId'] ?? '',
          isRecurring: json['isRecurring'] ?? false,
          reminderEnabled: json['reminderEnabled'] ?? true,
          reminderTime: json['reminderTime'] ?? '09:00 AM',
          status: json['status'] ?? 'Upcoming',
          createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
        )).toList();
        state = items;
      }
    } catch (e) {
      debugPrint('Error fetching bills: $e');
    }
  }

  Future<void> addBill(BillItem bill) async {
    state = [bill, ...state];
    try {
      final res = await _dioClient.post(
        ApiEndpoints.bills,
        data: {
          'id': bill.id,
          'name': bill.name,
          'category': bill.category,
          'amount': bill.amount,
          'dueDate': bill.dueDate,
          'frequency': bill.frequency,
          'paymentMethod': bill.paymentMethod,
          'walletId': bill.walletId,
          'isRecurring': bill.isRecurring,
          'reminderEnabled': bill.reminderEnabled,
          'reminderTime': bill.reminderTime,
        },
      );
      if (res.statusCode == 201) {
        await fetchBills();
      }
    } catch (e) {
      debugPrint('Error adding bill: $e');
    }
  }

  Future<void> deleteBill(String id) async {
    state = state.where((b) => b.id != id).toList();
    try {
      await _dioClient.delete('${ApiEndpoints.bills}/$id');
      await fetchBills();
    } catch (e) {
      debugPrint('Error deleting bill: $e');
    }
  }

  void recordPayment(String billId, BillPaymentRecord paymentRecord) {
    state = state.map((b) {
      if (b.id == billId) {
        final updatedHistory = [paymentRecord, ...b.paymentHistory];
        return b.copyWith(
          status: 'Paid',
          paymentHistory: updatedHistory,
          updatedAt: DateTime.now(),
        );
      }
      return b;
    }).toList();
  }

  void updateBillStatus(String billId, String newStatus) {
    state = state.map((b) {
      if (b.id == billId) {
        return b.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }
      return b;
    }).toList();
  }

  void updateBill(BillItem updatedBill) {
    state = state.map((b) => b.id == updatedBill.id ? updatedBill : b).toList();
  }
}


final billsProvider = StateNotifierProvider<BillsNotifier, List<BillItem>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BillsNotifier(dioClient, ref);
});
