import '../services/firebase_auth_service.dart';

/// Legacy TokenStorage helper bridging to Firebase Auth session
class TokenStorage {
  static void saveToken(String token) {}

  static String? getToken() {
    return FirebaseAuthService.currentUser?.uid;
  }

  static void clearToken() {
    FirebaseAuthService.signOut();
  }
}
