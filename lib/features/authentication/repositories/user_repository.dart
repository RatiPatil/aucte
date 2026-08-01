/// AUCTE — User Repository with Firestore & In-Memory Fallback.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  UserModel? _mockUser;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  void setMockUser({
    required String email,
    required String displayName,
    required UserRole role,
    String? hospital,
    String? department,
  }) {
    _mockUser = UserModel(
      uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      role: role,
      approved: true,
      hospital: hospital ?? 'All India Institute of Ayurveda',
      department: department ?? 'Clinical Terminology Wing',
      designation: role.label,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  UserModel? get mockUser => _mockUser;

  Future<UserModel?> getUser(String uid) async {
    if (_mockUser != null) return _mockUser;

    try {
      final doc = await _users.doc(uid).get().timeout(const Duration(seconds: 3));
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      return _mockUser;
    }
  }

  Future<void> createUser(UserModel user) async {
    _mockUser = user;
    try {
      await _users.doc(user.uid).set(user.toJson()).timeout(const Duration(seconds: 3));
    } catch (e) {
      // Offline fallback
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _users.doc(uid).update(data).timeout(const Duration(seconds: 3));
    } catch (e) {
      // Offline fallback
    }
  }
}
