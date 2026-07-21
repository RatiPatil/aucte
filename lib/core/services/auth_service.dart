/// AUCTE — Firebase Auth service wrapper.
///
/// Provides a clean API over FirebaseAuth for sign-in, sign-out,
/// and auth state observation. Falls back to demo mode when Firebase
/// is not initialized.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth =
          FirebaseConfig.isInitialized
              ? (firebaseAuth ?? FirebaseAuth.instance)
              : null;

  final FirebaseAuth? _firebaseAuth;

  /// Whether we are running with a real Firebase backend.
  bool get isLive => _firebaseAuth != null;

  /// Stream of auth state changes. Emits null when signed out.
  Stream<User?> get authStateChanges =>
      _firebaseAuth?.authStateChanges() ?? Stream.value(null);

  /// Currently signed-in user, or null.
  User? get currentUser => _firebaseAuth?.currentUser;

  /// Sign in with email and password.
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_firebaseAuth == null) {
      debugPrint('[AUCTE] Demo mode — skipping real sign-in.');
      return null;
    }
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create a new account with email and password.
  Future<UserCredential?> createAccount({
    required String email,
    required String password,
  }) async {
    if (_firebaseAuth == null) return null;
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out.
  Future<void> signOut() async {
    if (_firebaseAuth == null) return;
    await _firebaseAuth.signOut();
  }

  /// Send a password-reset email.
  Future<void> resetPassword(String email) async {
    if (_firebaseAuth == null) return;
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
