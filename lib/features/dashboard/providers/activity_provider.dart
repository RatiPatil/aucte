/// AUCTE — Activity Provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/activity_log_model.dart';
import '../repositories/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

final recentActivitiesProvider = StreamProvider<List<ActivityLogModel>>((ref) {
  final user = ref.watch(firebaseAuthProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  
  return ref.watch(activityRepositoryProvider).watchRecentActivities(user.uid);
});
