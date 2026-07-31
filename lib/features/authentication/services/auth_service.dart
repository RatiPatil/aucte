/// AUCTE — Auth Service.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/audit_log_model.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../repositories/audit_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

class AuthService {
  AuthService({
    required AuthRepository authRepo,
    required UserRepository userRepo,
    required AuditRepository auditRepo,
  })  : _authRepo = authRepo,
        _userRepo = userRepo,
        _auditRepo = auditRepo;

  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final AuditRepository _auditRepo;

  Stream<User?> get authStateChanges => _authRepo.authStateChanges;
  User? get currentUser => _authRepo.currentUser;

  Future<void> signInWithGoogle() async {
    try {
      final credential = await _authRepo.signInWithGoogle();
      if (credential != null && credential.user != null) {
        final user = credential.user!;
        _auditRepo.logAction(AuditLogModel(
          userId: user.uid,
          email: user.email ?? '',
          action: AuditAction.login,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        )).catchError((e) {
          debugPrint('Failed to log audit: $e');
        });
      }
    } catch (e) {
      if (_authRepo.currentUser != null) {
        _auditRepo.logAction(AuditLogModel(
          userId: _authRepo.currentUser!.uid,
          email: _authRepo.currentUser!.email ?? '',
          action: AuditAction.login,
          status: AuditStatus.failed,
          timestamp: DateTime.now(),
        )).catchError((e) {
          debugPrint('Failed to log audit: $e');
        });
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (currentUser != null) {
      _auditRepo.logAction(AuditLogModel(
        userId: currentUser!.uid,
        email: currentUser!.email ?? '',
        action: AuditAction.logout,
        status: AuditStatus.success,
        timestamp: DateTime.now(),
      )).catchError((e) {
        debugPrint('Failed to log audit: $e');
      });
    }
    await _authRepo.signOut();
  }
}
