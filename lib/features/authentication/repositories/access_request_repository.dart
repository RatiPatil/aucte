/// AUCTE — Access Request Repository.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/access_request_model.dart';

class AccessRequestRepository {
  AccessRequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('access_requests');

  Future<void> createRequest(AccessRequestModel request) async {
    await _requests.doc(request.requestId).set(request.toJson());
  }

  Future<AccessRequestModel?> getRequestByUid(String uid) async {
    final snapshot = await _requests.where('uid', isEqualTo: uid).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return AccessRequestModel.fromJson(snapshot.docs.first.data());
  }
}
