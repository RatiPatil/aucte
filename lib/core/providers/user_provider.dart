/// AUCTE — User Provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/authentication/models/user_role.dart';
import '../../features/dashboard/models/activity_log_model.dart';
import '../../features/dashboard/repositories/activity_repository.dart';
import 'auth_provider.dart';

final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final firebaseUser = await ref.watch(firebaseAuthProvider.future);
  if (firebaseUser == null) {
    yield null;
    return;
  }
  
  final userRepo = ref.watch(userRepositoryProvider);
  final user = await userRepo.getUser(firebaseUser.uid);
  
  if (user == null) {
    // Auto-provisioning for development/presentation
    final newUser = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? 'unknown@aucte.gov.in',
      displayName: firebaseUser.displayName ?? 'Dr. Clinician',
      photoUrl: firebaseUser.photoURL,
      role: UserRole.doctor,
      approved: true,
      hospital: 'AUCTE Network Hospital',
      department: 'General',
      designation: 'Doctor',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    userRepo.createUser(newUser).catchError((e) {
      debugPrint('Failed to auto-provision user: $e');
    });
    
    // Auto-seed some dummy activities for the new user
    final activityRepo = ActivityRepository();
    final now = DateTime.now();
    activityRepo.addActivity(ActivityLogModel(
      id: '',
      userId: firebaseUser.uid,
      title: 'Consultation: Raktamokshana',
      subtitle: 'Patient ID: PT-8291',
      iconName: 'medical_services_outlined',
      timestamp: now.subtract(const Duration(minutes: 5)),
    ));
    activityRepo.addActivity(ActivityLogModel(
      id: '',
      userId: firebaseUser.uid,
      title: 'FHIR Bundle Generated',
      subtitle: 'Mapped to WHO TM2',
      iconName: 'data_object_outlined',
      timestamp: now.subtract(const Duration(hours: 1)),
    ));
    activityRepo.addActivity(ActivityLogModel(
      id: '',
      userId: firebaseUser.uid,
      title: 'Terminology Synced',
      subtitle: 'NAMASTE v2.1 Update',
      iconName: 'sync_outlined',
      timestamp: now.subtract(const Duration(hours: 3)),
    ));
    
    yield newUser;
  } else {
    // Update last login
    userRepo.updateUser(user.uid, {'lastLogin': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
      debugPrint('Failed to update last login: $e');
    });
    yield user.copyWith(lastLogin: DateTime.now());
  }
});

final roleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.role ?? UserRole.unknown;
});
