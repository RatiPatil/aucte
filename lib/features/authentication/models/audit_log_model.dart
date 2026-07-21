/// AUCTE — Audit Log Model.
library;

enum AuditAction { login, logout, createRequest, updateProfile }
enum AuditStatus { success, failed }

class AuditLogModel {
  const AuditLogModel({
    required this.userId,
    required this.email,
    required this.action,
    required this.status,
    required this.timestamp,
    this.device,
    this.platform,
  });

  final String userId;
  final String email;
  final AuditAction action;
  final AuditStatus status;
  final DateTime timestamp;
  final String? device;
  final String? platform;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'action': action.name,
      'status': status.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'device': device,
      'platform': platform,
    };
  }
}
