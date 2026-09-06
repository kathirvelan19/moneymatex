import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth_onboarding/presentation/providers/auth_provider.dart';

class GoalContributionRecord {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String note;

  const GoalContributionRecord({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note = '',
  });
}

class GoalItem {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String targetDate;
  final String category;
  final String priority; // "High", "Medium", "Low"
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // "In Progress", "Completed", "Needs Attention"
  final List<GoalContributionRecord> contributions;
  final String notes;

  const GoalItem({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.category,
    this.priority = 'Medium',
    required this.createdAt,
    required this.updatedAt,
    this.status = 'In Progress',
    this.contributions = const [],
    this.notes = '',
  });

  double get remainingAmount => (targetAmount - savedAmount).clamp(0.0, targetAmount);

  double get progressPercentage =>
      targetAmount > 0 ? ((savedAmount / targetAmount) * 100).clamp(0.0, 100.0) : 0.0;

  GoalItem copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    String? targetDate,
    String? category,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    List<GoalContributionRecord>? contributions,
    String? notes,
  }) {
    return GoalItem(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      contributions: contributions ?? this.contributions,
      notes: notes ?? this.notes,
    );
  }
}

class GoalsNotifier extends StateNotifier<List<GoalItem>> {
  final DioClient _dioClient;
  final Ref _ref;

  GoalsNotifier(this._dioClient, this._ref) : super([]) {
    _init();
  }

  void _init() {
    fetchGoals();
    _ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.isAuthenticated) {
        fetchGoals();
      } else {
        state = [];
      }
    });
  }

  Future<void> fetchGoals() async {
    try {
      final res = await _dioClient.get(ApiEndpoints.goals);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data;
        final items = list.map((json) {
          final contribsList = (json['contributions'] as List?) ?? [];
          return GoalItem(
            id: json['id'] ?? '',
            name: json['name'] ?? '',
            targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
            savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
            targetDate: json['targetDate'] ?? '',
            category: json['category'] ?? 'Savings',
            priority: json['priority'] ?? 'Medium',
            createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
            status: json['status'] ?? 'In Progress',
            notes: json['notes'] ?? '',
            contributions: contribsList.map((c) => GoalContributionRecord(
              id: c['id'] ?? '',
              goalId: c['goalId'] ?? '',
              amount: (c['amount'] as num?)?.toDouble() ?? 0.0,
              date: DateTime.tryParse(c['date'] ?? '') ?? DateTime.now(),
              note: c['note'] ?? '',
            )).toList(),
          );
        }).toList();
        state = items;
      }
    } catch (e) {
      debugPrint('Error fetching goals: $e');
    }
  }

  Future<void> addGoal(GoalItem goal) async {
    state = [goal, ...state];
    try {
      final res = await _dioClient.post(
        ApiEndpoints.goals,
        data: {
          'id': goal.id,
          'name': goal.name,
          'targetAmount': goal.targetAmount,
          'savedAmount': goal.savedAmount,
          'targetDate': goal.targetDate,
          'category': goal.category,
          'priority': goal.priority,
          'notes': goal.notes,
        },
      );
      if (res.statusCode == 201) {
        await fetchGoals();
      }
    } catch (e) {
      debugPrint('Error adding goal: $e');
    }
  }

  Future<void> updateGoal(GoalItem updatedGoal) async {
    state = state.map((g) => g.id == updatedGoal.id ? updatedGoal : g).toList();
  }

  Future<void> deleteGoal(String id) async {
    state = state.where((g) => g.id != id).toList();
    try {
      await _dioClient.delete('${ApiEndpoints.goals}/$id');
      await fetchGoals();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }

  Future<void> addContribution(String goalId, double contributionAmount, {String note = ''}) async {
    final record = GoalContributionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: goalId,
      amount: contributionAmount,
      date: DateTime.now(),
      note: note,
    );
    state = state.map((g) {
      if (g.id == goalId) {
        final newSaved = g.savedAmount + contributionAmount;
        final newContribs = [record, ...g.contributions];
        return g.copyWith(
          savedAmount: newSaved,
          contributions: newContribs,
          updatedAt: DateTime.now(),
          status: newSaved >= g.targetAmount ? 'Completed' : 'In Progress',
        );
      }
      return g;
    }).toList();

    try {
      final res = await _dioClient.post(
        '${ApiEndpoints.goals}/$goalId/contributions',
        data: {'amount': contributionAmount, 'note': note},
      );
      if (res.statusCode == 200) {
        await fetchGoals();
      }
    } catch (e) {
      debugPrint('Error adding contribution: $e');
    }
  }
}


final goalsProvider = StateNotifierProvider<GoalsNotifier, List<GoalItem>>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GoalsNotifier(dioClient, ref);
});
