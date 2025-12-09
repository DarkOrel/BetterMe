import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';

/// Firebase Authentication service
class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Ensures a Firebase user is signed in (anonymous if needed)
  /// Returns the User on success, null on failure
  Future<User?> ensureSignedIn() async {
    if (!AppConfig.kUseFirebaseBackend) {
      return null;
    }

    // If already signed in, return current user
    final current = _auth.currentUser;
    if (current != null) {
      return current;
    }

    // Sign in anonymously
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } catch (e, stack) {
      debugPrint('Anonymous sign-in failed: $e\n$stack');
      return null;
    }
  }

  /// Sign in anonymously
  /// Returns the UserCredential on success, null on failure
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } catch (e, stack) {
      debugPrint('Anonymous sign-in failed: $e\n$stack');
      return null;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      debugPrint('Sign out failed: $e\n$stack');
    }
  }
}

/// Firebase Auth service provider
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

