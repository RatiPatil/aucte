/// AUCTE — Auth Providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/authentication/repositories/auth_repository.dart';
import '../../features/authentication/repositories/user_repository.dart';
import '../../features/authentication/repositories/audit_repository.dart';
import '../../features/authentication/repositories/access_request_repository.dart';
import '../../features/authentication/services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
final auditRepositoryProvider = Provider<AuditRepository>((ref) => AuditRepository());
final accessRequestRepositoryProvider = Provider<AccessRequestRepository>((ref) => AccessRequestRepository());

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    authRepo: ref.watch(authRepositoryProvider),
    userRepo: ref.watch(userRepositoryProvider),
    auditRepo: ref.watch(auditRepositoryProvider),
  );
});

final firebaseAuthProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
