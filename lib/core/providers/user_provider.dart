/// AUCTE — User Provider (Strict Authentication & Authorization).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/authentication/models/user_role.dart';
import 'auth_provider.dart';

final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final firebaseUser = await ref.watch(firebaseAuthProvider.future);

  if (firebaseUser == null) {
    debugPrint('[AUTH] Firebase user: null -> Status: unauthenticated');
    yield null;
    return;
  }

  debugPrint('[AUTH] Firebase user: ${firebaseUser.uid} (${firebaseUser.email})');
  debugPrint('[AUTH] Loading Firestore profile: users/${firebaseUser.uid}');

  final userRepo = ref.watch(userRepositoryProvider);
  final user = await userRepo.getUser(firebaseUser.uid);

  if (user == null) {
    debugPrint('[AUTH] Profile not found in Firestore for ${firebaseUser.uid}');
    yield null;
  } else {
    debugPrint('[AUTH] Profile loaded: approved=${user.approved}, role=${user.role.name}');
    userRepo.updateUser(user.uid, {'lastLogin': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
      debugPrint('[AUTH] Failed to update lastLogin: $e');
    });
    yield user.copyWith(lastLogin: DateTime.now());
  }
});

final roleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.role ?? UserRole.unknown;
});
