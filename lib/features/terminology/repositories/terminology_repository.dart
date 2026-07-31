/// AUCTE — Terminology Repository.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/namaste_code_model.dart';

abstract class ITerminologyRepository {
  Future<List<NamasteCodeModel>> searchNamaste(String query);
  Future<NamasteCodeModel?> getTerminologyByCode(String code);
  Future<List<NamasteCodeModel>> getPopularTerms();
  Future<void> seedDummyData();
}

class FirestoreTerminologyRepository implements ITerminologyRepository {
  FirestoreTerminologyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _namasteCodes =>
      _firestore.collection('namaste_codes');

  @override
  Future<List<NamasteCodeModel>> searchNamaste(String query) async {
    if (query.trim().isEmpty) return [];

    final searchTerm = query.trim().toLowerCase();
    
    // In Firestore, a prefix search is done using >= query and < query + \uf8ff
    try {
      final snapshot = await _namasteCodes
          .where('nameSearch', isGreaterThanOrEqualTo: searchTerm)
          .where('nameSearch', isLessThan: '$searchTerm\uf8ff')
          .where('isActive', isEqualTo: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => NamasteCodeModel.fromJson({'code': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Error searching NAMASTE: $e');
      return [];
    }
  }

  @override
  Future<NamasteCodeModel?> getTerminologyByCode(String code) async {
    try {
      final doc = await _namasteCodes.doc(code).get();
      if (!doc.exists) return null;
      return NamasteCodeModel.fromJson({'code': doc.id, ...doc.data()!});
    } catch (e) {
      debugPrint('Error fetching terminology by code: $e');
      return null;
    }
  }

  @override
  Future<List<NamasteCodeModel>> getPopularTerms() async {
    try {
      final snapshot = await _namasteCodes
          .where('isActive', isEqualTo: true)
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => NamasteCodeModel.fromJson({'code': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Error fetching popular terms: $e');
      return [];
    }
  }

  @override
  Future<void> seedDummyData() async {
    final snapshot = await _namasteCodes.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      // Already seeded
      return;
    }

    final dummyTerms = [
      NamasteCodeModel(
        code: 'NA-01-01-001',
        name: 'Jwara',
        system: 'Ayurveda',
        category: 'Kaya Chikitsa',
        definition: 'Fever. A condition characterized by increased body temperature, blocked sweating, and generalized body ache.',
        synonyms: ['Fever', 'Pyrexia'],
        isActive: true,
        nameSearch: 'jwara',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      NamasteCodeModel(
        code: 'NA-01-01-002',
        name: 'Jwara (Pittaja)',
        system: 'Ayurveda',
        category: 'Kaya Chikitsa',
        definition: 'Fever caused by aggravation of Pitta dosha, characterized by high temperature and burning sensation.',
        synonyms: ['Pitta Fever'],
        isActive: true,
        nameSearch: 'jwara (pittaja)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      NamasteCodeModel(
        code: 'NA-01-01-003',
        name: 'Jwara (Vataja)',
        system: 'Ayurveda',
        category: 'Kaya Chikitsa',
        definition: 'Fever caused by aggravation of Vata dosha.',
        synonyms: ['Vata Fever'],
        isActive: true,
        nameSearch: 'jwara (vataja)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      NamasteCodeModel(
        code: 'NA-02-04-015',
        name: 'Kasa',
        system: 'Ayurveda',
        category: 'Pranavaha Srotas',
        definition: 'Cough. A sudden, forceful hacking sound to release air and clear an irritation.',
        synonyms: ['Cough'],
        isActive: true,
        nameSearch: 'kasa',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      NamasteCodeModel(
        code: 'NA-03-01-008',
        name: 'Shwasa',
        system: 'Ayurveda',
        category: 'Pranavaha Srotas',
        definition: 'Dyspnea or difficulty in breathing.',
        synonyms: ['Asthma', 'Breathlessness'],
        isActive: true,
        nameSearch: 'shwasa',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      NamasteCodeModel(
        code: 'NA-04-02-022',
        name: 'Amlapitta',
        system: 'Ayurveda',
        category: 'Annavaha Srotas',
        definition: 'Hyperacidity or acid peptic disease.',
        synonyms: ['Acidity', 'Acid Reflux'],
        isActive: true,
        nameSearch: 'amlapitta',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final batch = _firestore.batch();
    for (final term in dummyTerms) {
      final docRef = _namasteCodes.doc(term.code);
      batch.set(docRef, term.toJson());
    }

    await batch.commit();
  }
}
