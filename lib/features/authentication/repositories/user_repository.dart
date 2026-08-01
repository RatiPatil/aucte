/// AUCTE — User Repository (Strict Firestore User Operations).
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_lookup_result.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Fetches the user profile from Firestore `users/{uid}`.
  /// Returns a explicit [UserLookupResult] distinguishing found, missing, or timeout/error.
  Future<UserLookupResult> getUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get().timeout(const Duration(seconds: 4));
      if (!doc.exists || doc.data() == null) {
        debugPrint('[AUCTE UserRepository] Profile NOT FOUND for $uid');
        return UserLookupResult.notFound();
      }
      final user = UserModel.fromJson({'uid': doc.id, ...doc.data()!});
      debugPrint('[AUCTE UserRepository] Profile FOUND for $uid (approved=${user.approved}, role=${user.role.name})');
      return UserLookupResult.found(user);
    } on TimeoutException {
      debugPrint('[AUCTE UserRepository] Timeout fetching user profile for $uid');
      return UserLookupResult.timeout();
    } on FirebaseException catch (e) {
      debugPrint('[AUCTE UserRepository] FirebaseException [${e.code}] for $uid: ${e.message}');
      if (e.code == 'permission-denied') {
        return UserLookupResult.permissionDenied();
      }
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        return UserLookupResult.networkError('Network unavailable. Check internet connection.');
      }
      return UserLookupResult.unknownError(e.message ?? 'Firestore read failed.');
    } catch (e) {
      debugPrint('[AUCTE UserRepository] Error fetching user profile for $uid: $e');
      return UserLookupResult.unknownError(e.toString());
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
