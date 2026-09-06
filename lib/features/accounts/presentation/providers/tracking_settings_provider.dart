import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackingSettingsState {
  final bool automaticTracking;
  final bool automaticCategorization;
  final bool budgetAlerts;
  final bool smartSpendingAlerts;
  final bool notificationsTracking;
  final bool upiDetection;
  final bool requireConfirmation;
  final bool duplicateDetection;

  const TrackingSettingsState({
    this.automaticTracking = false,
    this.automaticCategorization = true,
    this.budgetAlerts = true,
    this.smartSpendingAlerts = true,
    this.notificationsTracking = false,
    this.upiDetection = false,
    this.requireConfirmation = true,
    this.duplicateDetection = true,
  });

  TrackingSettingsState copyWith({
    bool? automaticTracking,
    bool? automaticCategorization,
    bool? budgetAlerts,
    bool? smartSpendingAlerts,
    bool? notificationsTracking,
    bool? upiDetection,
    bool? requireConfirmation,
    bool? duplicateDetection,
  }) {
    return TrackingSettingsState(
      automaticTracking: automaticTracking ?? this.automaticTracking,
      automaticCategorization: automaticCategorization ?? this.automaticCategorization,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      smartSpendingAlerts: smartSpendingAlerts ?? this.smartSpendingAlerts,
      notificationsTracking: notificationsTracking ?? this.notificationsTracking,
      upiDetection: upiDetection ?? this.upiDetection,
      requireConfirmation: requireConfirmation ?? this.requireConfirmation,
      duplicateDetection: duplicateDetection ?? this.duplicateDetection,
    );
  }
}

class TrackingSettingsNotifier extends StateNotifier<TrackingSettingsState> {
  TrackingSettingsNotifier() : super(const TrackingSettingsState());

  void setAutomaticTracking(bool value) {
    state = state.copyWith(automaticTracking: value);
  }

  void setAutomaticCategorization(bool value) {
    state = state.copyWith(automaticCategorization: value);
  }

  void setBudgetAlerts(bool value) {
    state = state.copyWith(budgetAlerts: value);
  }

  void setSmartSpendingAlerts(bool value) {
    state = state.copyWith(smartSpendingAlerts: value);
  }

  void setNotificationsTracking(bool value) {
    state = state.copyWith(notificationsTracking: value);
  }

  void setUpiDetection(bool value) {
    state = state.copyWith(upiDetection: value);
  }

  void setRequireConfirmation(bool value) {
    state = state.copyWith(requireConfirmation: value);
  }

  void setDuplicateDetection(bool value) {
    state = state.copyWith(duplicateDetection: value);
  }
}

final trackingSettingsProvider = StateNotifierProvider<TrackingSettingsNotifier, TrackingSettingsState>((ref) {
  return TrackingSettingsNotifier();
});
