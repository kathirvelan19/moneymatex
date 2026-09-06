import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/firebase_auth_service.dart';

/// Represents MoneyMateX authentication state & onboarding status
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isSessionChecked;
  final bool isOnboardingCompleted;
  final String? email;
  final String? name;
  final String? userId;
  final String? photoUrl;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isSessionChecked = false,
    this.isOnboardingCompleted = false,
    this.email,
    this.name,
    this.userId,
    this.photoUrl,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isSessionChecked,
    bool? isOnboardingCompleted,
    String? email,
    String? name,
    String? userId,
    String? photoUrl,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isSessionChecked: isSessionChecked ?? this.isSessionChecked,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      email: email ?? this.email,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      photoUrl: photoUrl ?? this.photoUrl,
      error: error,
    );
  }
}

/// StateNotifier for controlling authentication state backed by Firebase Auth & SharedPreferences
class AuthNotifier extends StateNotifier<AuthState> {
  StreamSubscription<User?>? _authSubscription;

  AuthNotifier() : super(const AuthState()) {
    _initAuthListener();
    checkSession();
  }

  void _initAuthListener() {
    _authSubscription = FirebaseAuthService.authStateChanges.listen((user) async {
      if (user != null) {
        final completed = await _checkOnboardingStatus(user.uid);
        state = AuthState(
          isAuthenticated: true,
          isLoading: false,
          isSessionChecked: true,
          isOnboardingCompleted: completed,
          email: user.email,
          name: user.displayName ?? user.email,
          userId: user.uid,
          photoUrl: user.photoURL,
        );
      } else {
        state = const AuthState(
          isAuthenticated: false,
          isLoading: false,
          isSessionChecked: true,
          isOnboardingCompleted: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _checkOnboardingStatus(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_completed_$uid') ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('[AUTH] SharedPreferences checkOnboardingStatus error: $e');
      }
      return false;
    }
  }

  /// Mark onboarding as completed for current Firebase UID
  Future<void> completeOnboarding() async {
    final uid = state.userId ?? FirebaseAuthService.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_completed_$uid', true);
      } catch (e) {
        if (kDebugMode) {
          print('[AUTH] SharedPreferences completeOnboarding error: $e');
        }
      }
    }
    state = state.copyWith(isOnboardingCompleted: true);
  }

  /// Check current Firebase Auth session and onboarding status
  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true);
    final user = FirebaseAuthService.currentUser;
    if (user != null) {
      final completed = await _checkOnboardingStatus(user.uid);
      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        isSessionChecked: true,
        isOnboardingCompleted: completed,
        email: user.email,
        name: user.displayName ?? user.email,
        userId: user.uid,
        photoUrl: user.photoURL,
      );
    } else {
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        isSessionChecked: true,
        isOnboardingCompleted: false,
      );
    }
  }

  /// Sign in with Google exclusively via Firebase Auth
  Future<bool> loginWithGoogle() async {
    if (kDebugMode) {
      print('====================================================');
      print('[AUTH] GOOGLE SIGN-IN STARTED');
      print('====================================================');
    }

    try {
      state = state.copyWith(isLoading: true, error: null);
      final userCredential = await FirebaseAuthService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        final completed = await _checkOnboardingStatus(user.uid);
        state = AuthState(
          isAuthenticated: true,
          isLoading: false,
          isSessionChecked: true,
          isOnboardingCompleted: completed,
          email: user.email,
          name: user.displayName ?? user.email,
          userId: user.uid,
          photoUrl: user.photoURL,
        );
        return true;
      }

      // User cancelled account selection
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign-in was cancelled.',
      );
      return false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('[AUTH] FirebaseAuthException: ${e.code} - ${e.message}');
      }
      state = state.copyWith(
        isLoading: false,
        error: _parseFirebaseError(e),
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[AUTH] Unexpected Google Sign-In error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to sign in with Google. Please check your network connection.',
      );
      return false;
    }
  }

  /// Sign out from Firebase Auth
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await FirebaseAuthService.signOut();
    } catch (_) {}
    state = const AuthState(
      isAuthenticated: false,
      isLoading: false,
      isSessionChecked: true,
      isOnboardingCompleted: false,
    );
  }

  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different credential.';
      case 'invalid-credential':
        return 'Invalid authentication credential provided.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled for this project.';
      case 'user-disabled':
        return 'This Google user account has been disabled.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet.';
      default:
        return e.message ?? 'This Google account could not be authenticated.';
    }
  }
}

/// Riverpod Provider exposing AuthState
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
