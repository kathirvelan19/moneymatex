import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Centralized Firebase Authentication Service for MoneyMateX
class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Returns current authenticated Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google using standard Firebase Auth flow
  static Future<UserCredential?> signInWithGoogle() async {
    if (kDebugMode) {
      print('[AUTH] Google sign-in started');
    }

    try {
      if (kIsWeb) {
        // Web Platform Google Authentication via Firebase Auth Popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final credential = await _auth.signInWithPopup(googleProvider);
        if (kDebugMode) {
          print('[AUTH] Firebase authentication successful (Web)');
          print('[AUTH] User UID: ${credential.user?.uid}');
        }
        return credential;
      } else {
        // Native Platforms (Android/iOS) Google Authentication
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          if (kDebugMode) {
            print('[AUTH] Google sign-in cancelled by user');
          }
          return null; // User cancelled the sign-in flow
        }
        if (kDebugMode) {
          print('[AUTH] Google account selected: ${googleUser.email}');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        if (kDebugMode) {
          print('[AUTH] Firebase credential created');
        }

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        if (kDebugMode) {
          print('[AUTH] Firebase authentication successful');
          print('[AUTH] User UID: ${userCredential.user?.uid}');
        }
        return userCredential;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AUTH] Google Sign-In error: $e');
      }
      rethrow;
    }
  }

  /// Sign out current Firebase user and clear Google Sign-In session
  static Future<void> signOut() async {
    if (kDebugMode) {
      print('[AUTH] Signing out user');
    }
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AUTH] GoogleSignIn signOut notice: $e');
      }
    }
    await _auth.signOut();
  }
}
