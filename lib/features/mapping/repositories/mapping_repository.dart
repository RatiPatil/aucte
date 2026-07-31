/// AUCTE — Mapping Repository.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/concept_map_model.dart';
import '../models/icd11_code_model.dart';
import '../models/tm2_code_model.dart';

abstract class IMappingRepository {
  Future<TM2CodeModel?> getTM2ByCode(String code);
  Future<ICD11CodeModel?> getICD11ByCode(String code);
  Future<ConceptMapModel?> getMappingByNamaste(String namasteCode);
  Future<void> seedDummyData();
}

class FirestoreMappingRepository implements IMappingRepository {
  FirestoreMappingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tm2Codes =>
      _firestore.collection('tm2_codes');

  CollectionReference<Map<String, dynamic>> get _icd11Codes =>
      _firestore.collection('icd11_codes');

  CollectionReference<Map<String, dynamic>> get _conceptMaps =>
      _firestore.collection('concept_maps');

  @override
  Future<TM2CodeModel?> getTM2ByCode(String code) async {
    try {
      final doc = await _tm2Codes.doc(code).get();
      if (!doc.exists) return null;
      return TM2CodeModel.fromJson({'code': doc.id, ...doc.data()!});
    } catch (e) {
      debugPrint('Error fetching TM2 by code: $e');
      return null;
    }
  }

  @override
  Future<ICD11CodeModel?> getICD11ByCode(String code) async {
    try {
      final doc = await _icd11Codes.doc(code).get();
      if (!doc.exists) return null;
      return ICD11CodeModel.fromJson({'code': doc.id, ...doc.data()!});
    } catch (e) {
      debugPrint('Error fetching ICD11 by code: $e');
      return null;
    }
  }

  @override
  Future<ConceptMapModel?> getMappingByNamaste(String namasteCode) async {
    try {
      final snapshot = await _conceptMaps
          .where('namasteCode', isEqualTo: namasteCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return ConceptMapModel.fromJson(doc.data());
    } catch (e) {
      debugPrint('Error fetching concept map: $e');
      return null;
    }
  }

  @override
  Future<void> seedDummyData() async {
    final snapshot = await _conceptMaps.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      // Already seeded
      return;
    }

    final batch = _firestore.batch();

    // 1. TM2 Codes
    final tm2Term = TM2CodeModel(
      code: 'SA02',
      title: 'Jvara',
      definition: 'A disorder characterized by elevated body temperature.',
      category: 'TM1 - Traditional Medicine Conditions',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    batch.set(_tm2Codes.doc(tm2Term.code), tm2Term.toJson());

    // 2. ICD11 Codes
    final icd11Term = ICD11CodeModel(
      code: 'MG26',
      title: 'Fever of other or unknown origin',
      definition: 'Fever (pyrexia) of unknown origin is a condition in which the patient has an elevated temperature.',
      chapter: '21 Symptoms, signs or clinical findings, not elsewhere classified',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    batch.set(_icd11Codes.doc(icd11Term.code), icd11Term.toJson());

    // 3. Concept Map (Jwara -> SA02 & MG26)
    final conceptMap = ConceptMapModel(
      namasteCode: 'NA-01-01-001',
      tm2Code: 'SA02',
      icd11Code: 'MG26',
      mappingType: 'Equivalent',
      confidence: 'High',
      remarks: 'Standard mapping provided by WHO technical advisory group.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Use an auto-ID or combination ID for the map
    final mapRef = _conceptMaps.doc('MAP-${conceptMap.namasteCode}');
    batch.set(mapRef, conceptMap.toJson());

    await batch.commit();
  }
}
