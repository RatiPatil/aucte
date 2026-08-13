import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/patient_model.dart';
import 'local_patient_repository.dart';
import 'patient_repository.dart';

class FirestorePatientRepository implements PatientRepository {
  FirestorePatientRepository._();

  static final FirestorePatientRepository instance =
      FirestorePatientRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalPatientRepository _localRepo = LocalPatientRepository.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _patientsCollection =>
      _firestore.collection('patients');

  @override
  Future<List<PatientModel>> getPatients() async {
    try {
      final snapshot = await _patientsCollection
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        // Fallback to local if empty or uninitialized
        final localList = await _localRepo.getPatients();
        return localList;
      }

      return snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firestore getPatients error, falling back to local: $e');
      return await _localRepo.getPatients();
    }
  }

  @override
  Future<List<PatientModel>> searchPatients(String query) async {
    try {
      final allPatients = await getPatients();
      if (query.trim().isEmpty) return allPatients;

      final q = query.trim().toLowerCase();
      return allPatients.where((p) {
        final nameMatches = p.fullName.toLowerCase().contains(q);
        final idMatches = p.id.toLowerCase().contains(q);
        final phoneMatches = p.mobile.contains(q);
        final abhaMatches = p.abhaNumber?.toLowerCase().contains(q) ?? false;
        return nameMatches || idMatches || phoneMatches || abhaMatches;
      }).toList();
    } catch (e) {
      debugPrint('Firestore searchPatients error: $e');
      return await _localRepo.searchPatients(query);
    }
  }

  @override
  Future<PatientModel?> getPatientById(String id) async {
    try {
      final doc = await _patientsCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return PatientModel.fromMap(doc.data()!);
      }
      return await _localRepo.getPatientById(id);
    } catch (e) {
      debugPrint('Firestore getPatientById error: $e');
      return await _localRepo.getPatientById(id);
    }
  }

  @override
  Future<PatientModel> addPatient(PatientModel patient) async {
    try {
      final currentUserId = _auth.currentUser?.uid ?? 'local_user';
      final patientId = patient.id.isEmpty
          ? 'AUC-PAT-${_uuid.v4().substring(0, 6).toUpperCase()}'
          : patient.id;

      final newPatient = patient.copyWith(
        id: patientId,
        createdBy: currentUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save locally first for instant feedback and offline support
      await _localRepo.addPatient(newPatient);

      // Background sync to Firestore without blocking the UI
      _patientsCollection.doc(patientId).set(newPatient.toMap()).catchError((e) {
        debugPrint('Firestore background add sync error: $e');
      });

      return newPatient;
    } catch (e) {
      debugPrint('addPatient error: $e');
      return await _localRepo.addPatient(patient);
    }
  }

  @override
  Future<void> updatePatient(PatientModel patient) async {
    try {
      final updatedPatient = patient.copyWith(updatedAt: DateTime.now());
      
      await _localRepo.updatePatient(updatedPatient);
      
      _patientsCollection.doc(patient.id).update(updatedPatient.toMap()).catchError((e) {
        debugPrint('Firestore background update sync error: $e');
      });
    } catch (e) {
      debugPrint('updatePatient error: $e');
      await _localRepo.updatePatient(patient);
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await _localRepo.deletePatient(id);
      
      _patientsCollection.doc(id).delete().catchError((e) {
        debugPrint('Firestore background delete sync error: $e');
      });
    } catch (e) {
      debugPrint('deletePatient error: $e');
      await _localRepo.deletePatient(id);
    }
  }
}
