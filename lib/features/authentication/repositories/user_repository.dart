/// AUCTE — User Repository (Strict Firestore User Operations).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Fetches the user profile from Firestore `users/{uid}`.
  /// Returns null if the user document does not exist or Firestore is unreachable.
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get().timeout(const Duration(seconds: 4));
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromJson({'uid': doc.id, ...doc.data()!});
    } catch (e) {
      debugPrint('[AUCTE UserRepository] Error fetching user profile for $uid: $e');
      return null;
    }
  }

  /// Creates a new user profile in Firestore `users/{uid}`.
  Future<void> createUser(UserModel user) async {
    try {
      await _users.doc(user.uid).set(user.toJson(), SetOptions(merge: true)).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[AUCTE UserRepository] Error creating user profile: $e');
      rethrow;
    }
  }

  /// Updates an existing user profile in Firestore `users/{uid}`.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _users.doc(uid).update(data).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[AUCTE UserRepository] Error updating user profile: $e');
      rethrow;
    }
  }
}
