/// AUCTE — Real-Time Dashboard Providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_provider.dart';
import '../models/activity_log_model.dart';
import '../models/dashboard_stats_model.dart';
import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardStatsStreamProvider = StreamProvider.autoDispose<DashboardStatsModel>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final userId = user?.uid ?? 'dr-sharma-001';
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchDashboardStats(userId);
});

final dashboardActivityStreamProvider = StreamProvider.autoDispose<List<ActivityLogModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final userId = user?.uid ?? 'dr-sharma-001';
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchRecentActivity(userId);
});
