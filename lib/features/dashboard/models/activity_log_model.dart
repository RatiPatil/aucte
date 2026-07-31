/// AUCTE — Activity Log Model.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogModel {
  const ActivityLogModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final String title;
  final String subtitle;
  final String iconName; // e.g., 'medical_services'
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'iconName': iconName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'info',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
