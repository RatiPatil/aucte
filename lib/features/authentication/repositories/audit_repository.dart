/// AUCTE — Audit Repository.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';

class AuditRepository {
  AuditRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _firestore.collection('audit_logs');

  Future<void> logAction(AuditLogModel log) async {
    await _logs.add(log.toJson());
  }
}
