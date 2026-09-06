import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import 'auth_provider.dart';

class UserProfileState {
  final String name;
  final String email;
  final String occupation;
  final String financialPriority;
  final double monthlyIncome;
  final double additionalIncome;
  final double monthlyExpensesEstimate;
  final double currentSavings;
  final double debtAmount;
  final String primaryGoal;
  final double goalTargetAmount;

  const UserProfileState({
    this.name = 'User',
    this.email = '',
    this.occupation = 'Professional',
    this.financialPriority = 'Manage Expenses',
    this.monthlyIncome = 0.0,
    this.additionalIncome = 0.0,
    this.monthlyExpensesEstimate = 0.0,
    this.currentSavings = 0.0,
    this.debtAmount = 0.0,
    this.primaryGoal = 'Emergency Fund',
    this.goalTargetAmount = 0.0,
  });

  double get totalIncome => monthlyIncome + additionalIncome;

  UserProfileState copyWith({
    String? name,
    String? email,
    String? occupation,
    String? financialPriority,
    double? monthlyIncome,
    double? additionalIncome,
    double? monthlyExpensesEstimate,
    double? currentSavings,
    double? debtAmount,
    String? primaryGoal,
    double? goalTargetAmount,
  }) {
    return UserProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      financialPriority: financialPriority ?? this.financialPriority,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      additionalIncome: additionalIncome ?? this.additionalIncome,
      monthlyExpensesEstimate: monthlyExpensesEstimate ?? this.monthlyExpensesEstimate,
      currentSavings: currentSavings ?? this.currentSavings,
      debtAmount: debtAmount ?? this.debtAmount,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      goalTargetAmount: goalTargetAmount ?? this.goalTargetAmount,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final DioClient _dioClient;
  final Ref _ref;

  UserProfileNotifier(this._dioClient, this._ref) : super(const UserProfileState()) {
    _init();
  }

  void _init() {
    fetchProfile();
    _ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.isAuthenticated) {
        fetchProfile();
      } else {
        state = const UserProfileState();
      }
    });
  }

  Future<void> fetchProfile() async {
    try {
      final res = await _dioClient.get('/profile');
      if (res.statusCode == 200 && res.data != null) {
        final json = res.data;
        state = UserProfileState(
          name: json['name'] ?? 'User',
          email: json['email'] ?? '',
          occupation: json['occupation'] ?? 'Professional',
          financialPriority: json['financialPriority'] ?? 'Manage Expenses',
          monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
          additionalIncome: (json['additionalIncome'] as num?)?.toDouble() ?? 0.0,
          monthlyExpensesEstimate: (json['monthlyExpensesEstimate'] as num?)?.toDouble() ?? 0.0,
          currentSavings: (json['currentSavings'] as num?)?.toDouble() ?? 0.0,
          debtAmount: (json['debtAmount'] as num?)?.toDouble() ?? 0.0,
          primaryGoal: json['primaryGoal'] ?? 'Emergency Fund',
          goalTargetAmount: (json['goalTargetAmount'] as num?)?.toDouble() ?? 0.0,
        );
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> saveProfile(UserProfileState profile) async {
    state = profile;
    try {
      await _dioClient.put(
        '/profile',
        data: {
          'name': profile.name,
          'occupation': profile.occupation,
          'financialPriority': profile.financialPriority,
          'monthlyIncome': profile.monthlyIncome,
          'additionalIncome': profile.additionalIncome,
          'monthlyExpensesEstimate': profile.monthlyExpensesEstimate,
          'currentSavings': profile.currentSavings,
          'debtAmount': profile.debtAmount,
          'primaryGoal': profile.primaryGoal,
          'goalTargetAmount': profile.goalTargetAmount,
        },
      );
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  void updateOccupation(String value) {
    saveProfile(state.copyWith(occupation: value));
  }

  void updatePriority(String value) {
    saveProfile(state.copyWith(financialPriority: value));
  }

  void updateMonthlyIncome(double value) {
    saveProfile(state.copyWith(monthlyIncome: value));
  }

  void updateAdditionalIncome(double value) {
    saveProfile(state.copyWith(additionalIncome: value));
  }

  void updateMonthlyExpenses(double value) {
    saveProfile(state.copyWith(monthlyExpensesEstimate: value));
  }

  void updateCurrentSavings(double value) {
    saveProfile(state.copyWith(currentSavings: value));
  }

  void updateDebtAmount(double value) {
    saveProfile(state.copyWith(debtAmount: value));
  }

  void updateGoal(String goal, double targetAmount) {
    saveProfile(state.copyWith(primaryGoal: goal, goalTargetAmount: targetAmount));
  }

  void updateUserInfo({String? name, String? email}) {
    saveProfile(state.copyWith(name: name ?? state.name, email: email ?? state.email));
  }

  void reset() {
    state = const UserProfileState();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UserProfileNotifier(dioClient, ref);
});
