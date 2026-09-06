import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth_onboarding/presentation/providers/auth_provider.dart';

class WalletItem {
  final String id;
  final String name;
  final String type; // Bank Account, Debit Card, Credit Card, UPI, Cash, Digital Wallet, Other
  final String provider;
  final double balance;
  final DateTime createdAt;
  final String trackingMethod; // Automatic vs Manual
  final bool isPrimary;

  const WalletItem({
    required this.id,
    required this.name,
    required this.type,
    required this.provider,
    required this.balance,
    required this.createdAt,
    required this.trackingMethod,
    this.isPrimary = false,
  });

  WalletItem copyWith({
    String? id,
    String? name,
    String? type,
    String? provider,
    double? balance,
    DateTime? createdAt,
    String? trackingMethod,
    bool? isPrimary,
  }) {
    return WalletItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      trackingMethod: trackingMethod ?? this.trackingMethod,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class UserWalletsNotifier extends StateNotifier<List<WalletItem>> {
  final DioClient _dioClient;
  final Ref _ref;

  UserWalletsNotifier(this._dioClient, this._ref) : super([]) {
    _init();
  }

  void _init() {
    fetchWallets();
    _ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.isAuthenticated) {
        fetchWallets();
      } else {
        state = [];
      }
    });
  }

  Future<void> fetchWallets() async {
    try {
      final res = await _dioClient.get(ApiEndpoints.wallets);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data;
        final items = list.map((json) => WalletItem(
          id: json['id'] ?? '',
          name: json['name'] ?? '',
          type: json['type'] ?? 'Bank Account',
          provider: json['provider'] ?? 'Bank',
          balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
          createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
          trackingMethod: json['trackingMethod'] ?? 'Manual',
          isPrimary: json['isPrimary'] ?? false,
        )).toList();
        state = items;
      }
    } catch (e) {
      debugPrint('Error fetching wallets: $e');
    }
  }

  Future<void> addWallet(WalletItem wallet) async {
    state = [...state, wallet];
    try {
      final res = await _dioClient.post(
        ApiEndpoints.wallets,
        data: {
          'id': wallet.id,
          'name': wallet.name,
          'type': wallet.type,
          'provider': wallet.provider,
          'balance': wallet.balance,
          'isPrimary': wallet.isPrimary,
          'trackingMethod': wallet.trackingMethod,
        },
      );
      if (res.statusCode == 201) {
        await fetchWallets();
      }
    } catch (e) {
      debugPrint('Error adding wallet: $e');
    }
  }

  Future<void> removeWallet(String id) async {
    state = state.where((w) => w.id != id).toList();
    try {
      await _dioClient.delete('${ApiEndpoints.wallets}/$id');
      await fetchWallets();
    } catch (e) {
      debugPrint('Error removing wallet: $e');
    }
  }

  void setPrimary(String id) {
    state = state.map((w) => w.copyWith(isPrimary: w.id == id)).toList();
  }

  void updateBalance(String identifier, double delta) {
    state = state.map((w) {
      if (w.id == identifier || w.name.toLowerCase() == identifier.toLowerCase()) {
        return w.copyWith(balance: (w.balance + delta).clamp(0.0, double.infinity));
      }
      return w;
    }).toList();
  }
}

final userWalletsProvider = StateNotifierProvider<UserWalletsNotifier, List<WalletItem>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UserWalletsNotifier(dioClient, ref);
});
