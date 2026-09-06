import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth_onboarding/presentation/providers/auth_provider.dart';
import '../../domain/entities/transaction_entity.dart';

/// StateNotifier providing persistent database-backed management for transactions
class TransactionsNotifier extends StateNotifier<List<TransactionItem>> {
  final DioClient _dioClient;
  final Ref _ref;

  TransactionsNotifier(this._dioClient, this._ref) : super([]) {
    _init();
  }

  void _init() {
    fetchTransactions();
    _ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.isAuthenticated) {
        fetchTransactions();
      } else {
        state = [];
      }
    });
  }

  Future<void> fetchTransactions() async {
    try {
      final res = await _dioClient.get(ApiEndpoints.transactions);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data;
        final items = list.map((json) {
          final cat = json['category'] ?? '';
          return TransactionItem(
            id: json['id'] ?? '',
            title: json['title'] ?? '',
            category: cat,
            amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
            isExpense: json['isExpense'] ?? true,
            date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
            paymentMethod: json['paymentMethod'] ?? 'Wallet',
            wallet: json['walletId'] ?? 'Wallet',
            notes: json['notes'] ?? '',
            icon: getCategoryIcon(cat),
          );
        }).toList();
        state = items;
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    state = [transaction, ...state];

    try {
      final res = await _dioClient.post(
        ApiEndpoints.transactions,
        data: {
          'id': transaction.id,
          'title': transaction.title,
          'category': transaction.category,
          'amount': transaction.amount,
          'isExpense': transaction.isExpense,
          'date': transaction.date.toIso8601String(),
          'paymentMethod': transaction.paymentMethod,
          'walletId': transaction.wallet,
          'notes': transaction.notes ?? '',
        },
      );
      if (res.statusCode == 201) {
        await fetchTransactions();
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    state = state.map((item) => item.id == transaction.id ? transaction : item).toList();

    try {
      final res = await _dioClient.put(
        '${ApiEndpoints.transactions}/${transaction.id}',
        data: {
          'id': transaction.id,
          'title': transaction.title,
          'category': transaction.category,
          'amount': transaction.amount,
          'isExpense': transaction.isExpense,
          'date': transaction.date.toIso8601String(),
          'paymentMethod': transaction.paymentMethod,
          'walletId': transaction.wallet,
          'notes': transaction.notes ?? '',
        },
      );
      if (res.statusCode == 200) {
        await fetchTransactions();
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }


  Future<void> deleteTransaction(String id) async {
    state = state.where((item) => item.id != id).toList();

    try {
      await _dioClient.delete('${ApiEndpoints.transactions}/$id');
      await fetchTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  void clearAll() {
    state = [];
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
      case 'Food':
        return Icons.restaurant;
      case 'Shopping & Lifestyle':
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Bills & Utilities':
        return Icons.receipt_long;
      case 'Housing & Rent':
      case 'Housing':
        return Icons.home_outlined;
      case 'Travel & Commute':
      case 'Travel':
      case 'Transport':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Health & Wellness':
        return Icons.medical_services_outlined;
      case 'Investments':
        return Icons.trending_up;
      case 'Income':
      case 'Salary':
        return Icons.arrow_downward;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}

/// Central Riverpod Provider for transactions list
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionItem>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TransactionsNotifier(dioClient, ref);
});
