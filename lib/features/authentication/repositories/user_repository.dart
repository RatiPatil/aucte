/// AUCTE — User Repository.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserModel?> getUser(String uid) async {
    try {
      // Add a 3-second timeout. If Firestore is blocked by network, it won't hang forever.
      final doc = await _users.doc(uid).get().timeout(const Duration(seconds: 3));
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      // Graceful fallback if Firestore is offline or times out.
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _users.doc(user.uid).set(user.toJson()).timeout(const Duration(seconds: 3));
    } catch (e) {
      // Ignore if offline
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _users.doc(uid).update(data).timeout(const Duration(seconds: 3));
    } catch (e) {
      // Ignore if offline
    }
  }
}
