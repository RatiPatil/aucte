/// AUCTE — Activity Repository.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_log_model.dart';

class ActivityRepository {
  ActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _activities =>
      _firestore.collection('activity_logs');

  Stream<List<ActivityLogModel>> watchRecentActivities(String userId, {int limit = 5}) {
    return _activities
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLogModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Future<void> addActivity(ActivityLogModel activity) async {
    try {
      final docRef = _activities.doc();
      final newActivity = ActivityLogModel(
        id: docRef.id,
        userId: activity.userId,
        title: activity.title,
        subtitle: activity.subtitle,
        iconName: activity.iconName,
        timestamp: activity.timestamp,
      );
      await docRef.set(newActivity.toJson()).timeout(const Duration(seconds: 3));
    } catch (e) {
      // Fire and forget, ignore if offline
    }
  }
}
