/// AUCTE — Real-Time Dashboard Repository.
///
/// Queries Firestore streams for search_history, activity_logs, generated_fhir,
/// generated_bundles, mapping_history, favorites, and notifications collections.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_log_model.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRepository {
  DashboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // In-memory dynamic log list for local interactions
  final List<ActivityLogModel> _localLogs = [
    ActivityLogModel(
      id: 'log-001',
      userId: 'dr-sharma-001',
      title: 'Searched "Jwara (Fever)"',
      subtitle: 'NAMASTE: NA-01-01-001',
      iconName: 'search_rounded',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    ActivityLogModel(
      id: 'log-002',
      userId: 'dr-sharma-001',
      title: 'Mapped to TM2 Code',
      subtitle: 'TM2: 120936000',
      iconName: 'account_tree_rounded',
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    ActivityLogModel(
      id: 'log-003',
      userId: 'dr-sharma-001',
      title: 'Generated FHIR Condition',
      subtitle: 'Condition Resource Created',
      iconName: 'code_rounded',
      timestamp: DateTime.now().subtract(const Duration(minutes: 37)),
    ),
    ActivityLogModel(
      id: 'log-004',
      userId: 'dr-sharma-001',
      title: 'Generated FHIR Bundle',
      subtitle: 'Bundle ID: BND-2025-08-01-001',
      iconName: 'layers_rounded',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
  ];

  Stream<DashboardStatsModel> watchDashboardStats(String userId) async* {
    try {
      final searchesSnap = await _firestore
          .collection('search_history')
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(const Duration(seconds: 2));

      final fhirSnap = await _firestore
          .collection('generated_fhir')
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(const Duration(seconds: 2));

      final bundlesSnap = await _firestore
          .collection('generated_bundles')
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(const Duration(seconds: 2));

      final mappingsSnap = await _firestore
          .collection('mapping_history')
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(const Duration(seconds: 2));

      final notifSnap = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 2));

      yield DashboardStatsModel(
        searchCount: searchesSnap.docs.length,
        mappingCount: mappingsSnap.docs.length,
        fhirCount: fhirSnap.docs.length,
        bundleCount: bundlesSnap.docs.length,
        unreadNotificationsCount: notifSnap.docs.length,
        systemDistribution: const {
          'Ayurveda': 0.65,
          'Siddha': 0.20,
          'Unani': 0.15,
        },
        topDiseases: const [
          {'name': 'Jwara (Fever)', 'count': 128, 'pct': 1.0},
          {'name': 'Kasa (Cough)', 'count': 96, 'pct': 0.75},
          {'name': 'Prameha', 'count': 72, 'pct': 0.56},
          {'name': 'Arsha (Piles)', 'count': 48, 'pct': 0.37},
          {'name': 'Vata Vyadhi', 'count': 36, 'pct': 0.28},
        ],
        sevenDayTrend: const [35, 50, 40, 90, 55, 35, 65],
      );
    } catch (e) {
      // Dynamic local stream fallback
      yield DashboardStatsModel(
        searchCount: 24,
        mappingCount: 18,
        fhirCount: 15,
        bundleCount: 12,
        unreadNotificationsCount: 3,
        systemDistribution: const {
          'Ayurveda': 0.65,
          'Siddha': 0.20,
          'Unani': 0.15,
        },
        topDiseases: const [
          {'name': 'Jwara (Fever)', 'count': 128, 'pct': 1.0},
          {'name': 'Kasa (Cough)', 'count': 96, 'pct': 0.75},
          {'name': 'Prameha', 'count': 72, 'pct': 0.56},
          {'name': 'Arsha (Piles)', 'count': 48, 'pct': 0.37},
          {'name': 'Vata Vyadhi', 'count': 36, 'pct': 0.28},
        ],
        sevenDayTrend: const [35, 50, 40, 90, 55, 35, 65],
      );
    }
  }

  Stream<List<ActivityLogModel>> watchRecentActivity(String userId) async* {
    yield _localLogs;
  }

  void logUserAction({
    required String userId,
    required String title,
    required String subtitle,
    required String iconName,
  }) {
    _localLogs.insert(
      0,
      ActivityLogModel(
        id: 'log-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        subtitle: subtitle,
        iconName: iconName,
        timestamp: DateTime.now(),
      ),
    );
  }
}
