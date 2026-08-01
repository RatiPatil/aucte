/// AUCTE — User Provider (Strict Authentication & Authorization).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../features/authentication/models/user_lookup_result.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/authentication/models/user_role.dart';
import 'auth_provider.dart';

final userLookupProvider = StreamProvider<UserLookupResult>((ref) async* {
  final firebaseUser = await ref.watch(firebaseAuthProvider.future);

  if (firebaseUser == null) {
    debugPrint('[AUTH] Firebase user: null -> Status: unauthenticated');
    yield UserLookupResult.notFound();
    return;
  }

  debugPrint('[AUTH] Firebase user: ${firebaseUser.uid} (${firebaseUser.email})');
  debugPrint('[AUTH] Loading Firestore profile: users/${firebaseUser.uid}');

  final userRepo = ref.watch(userRepositoryProvider);
  final result = await userRepo.getUser(firebaseUser.uid);

  if (result.isFound && result.profile != null) {
    final user = result.profile!;
    debugPrint('[AUTH] Profile loaded: approved=${user.approved}, role=${user.role.name}');
    userRepo.updateUser(user.uid, {'lastLogin': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
      debugPrint('[AUTH] Failed to update lastLogin: $e');
    });
  } else if (result.isNotFound) {
    debugPrint('[AUTH] Profile NOT FOUND in Firestore for ${firebaseUser.uid} -> Routing to Request Access');
  } else {
    debugPrint('[AUTH] Profile lookup FAILED for ${firebaseUser.uid}: ${result.errorMessage}');
  }

  yield result;
});

final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final lookupAsync = await ref.watch(userLookupProvider.future);
  yield lookupAsync.profile;
});

final roleProvider = Provider<UserRole>((ref) {
  final userAsync = ref.watch(currentUserProvider).valueOrNull;
  return userAsync?.role ?? UserRole.unknown;
});
