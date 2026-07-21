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
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toJson());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }
}
