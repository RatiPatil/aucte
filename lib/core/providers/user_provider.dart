/// AUCTE — User Provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/authentication/models/user_role.dart';
import 'auth_provider.dart';

final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final userRepo = ref.watch(userRepositoryProvider);
  if (userRepo.mockUser != null) {
    yield userRepo.mockUser;
    return;
  }

  final firebaseUser = await ref.watch(firebaseAuthProvider.future);
  if (firebaseUser == null) {
    yield userRepo.mockUser; // Returns null if no user is signed in
    return;
  }

  final user = await userRepo.getUser(firebaseUser.uid);

  if (user == null) {
    // Auto-provisioning for authenticated Firebase users
    final newUser = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? 'dr.ratikant@ayush.gov.in',
      displayName: firebaseUser.displayName ?? 'Dr. Ratikant',
      photoUrl: firebaseUser.photoURL,
      role: UserRole.doctor,
      approved: true,
      hospital: 'All India Institute of Ayurveda',
      department: 'Ayurveda Clinical Terminology Wing',
      designation: 'Government AYUSH Doctor',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    userRepo.createUser(newUser).catchError((e) {
      debugPrint('Failed to provision user: $e');
    });

    yield newUser;
  } else {
    userRepo.updateUser(user.uid, {'lastLogin': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
      debugPrint('Failed to update last login: $e');
    });
    yield user.copyWith(lastLogin: DateTime.now());
  }
});

final roleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.role ?? UserRole.doctor;
});
