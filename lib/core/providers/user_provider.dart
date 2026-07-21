/// AUCTE — User Provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/authentication/models/user_role.dart';
import 'auth_provider.dart';

final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final firebaseUser = await ref.watch(firebaseAuthProvider.future);
  if (firebaseUser == null) {
    yield null;
    return;
  }
  
  // Actually, listening to Firestore would be ideal so we get instant approval changes.
  final userRepo = ref.watch(userRepositoryProvider);
  yield await userRepo.getUser(firebaseUser.uid);
});

final roleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.role ?? UserRole.unknown;
});
