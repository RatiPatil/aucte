/// AUCTE — Terminology Repository with Automatic Offline Asset Fallback.
library;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  List<NamasteCodeModel>? _localAssetCache;

  CollectionReference<Map<String, dynamic>> get _namasteCodes =>
      _firestore.collection('namaste_codes');

  Future<List<NamasteCodeModel>> _loadLocalAsset() async {
    if (_localAssetCache != null) return _localAssetCache!;
    try {
      final jsonStr = await rootBundle.loadString('assets/datasets/namaste_codes.json');
      final List<dynamic> raw = jsonDecode(jsonStr);
      _localAssetCache = raw
          .map((item) => NamasteCodeModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return _localAssetCache!;
    } catch (e) {
      debugPrint('[AUCTE Repository] Error reading local asset: $e');
      return [];
    }
  }

  @override
  Future<List<NamasteCodeModel>> searchNamaste(String query) async {
    if (query.trim().isEmpty) return [];

    final searchTerm = query.trim().toLowerCase();

    try {
      final snapshot = await _namasteCodes
          .where('nameSearch', isGreaterThanOrEqualTo: searchTerm)
          .where('nameSearch', isLessThan: '$searchTerm\uf8ff')
          .where('isActive', isEqualTo: true)
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 2));

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => NamasteCodeModel.fromJson({'code': doc.id, ...doc.data()}))
            .toList();
      }
    } catch (e) {
      debugPrint('[AUCTE Repository] Firestore search offline fallback triggered: $e');
    }

    // Offline asset search fallback
    final all = await _loadLocalAsset();
    return all.where((term) {
      final matchName = term.name.toLowerCase().contains(searchTerm);
      final matchCode = term.code.toLowerCase().contains(searchTerm);
      final matchSyn = term.synonyms.any((s) => s.toLowerCase().contains(searchTerm));
      final matchCat = term.category.toLowerCase().contains(searchTerm);
      return matchName || matchCode || matchSyn || matchCat;
    }).take(20).toList();
  }

  @override
  Future<NamasteCodeModel?> getTerminologyByCode(String code) async {
    try {
      final doc = await _namasteCodes.doc(code).get().timeout(const Duration(seconds: 2));
      if (doc.exists) {
        return NamasteCodeModel.fromJson({'code': doc.id, ...doc.data()!});
      }
    } catch (e) {
      debugPrint('[AUCTE Repository] Firestore fetch offline fallback triggered: $e');
    }

    final all = await _loadLocalAsset();
    try {
      return all.firstWhere((term) => term.code.toUpperCase() == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<NamasteCodeModel>> getPopularTerms() async {
    try {
      final snapshot = await _namasteCodes
          .where('isActive', isEqualTo: true)
          .limit(5)
          .get()
          .timeout(const Duration(seconds: 2));

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => NamasteCodeModel.fromJson({'code': doc.id, ...doc.data()}))
            .toList();
      }
    } catch (e) {
      debugPrint('[AUCTE Repository] Firestore popular terms offline fallback triggered: $e');
    }

    final all = await _loadLocalAsset();
    return all.take(5).toList();
  }

  @override
  Future<void> seedDummyData() async {
    final snapshot = await _namasteCodes.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final all = await _loadLocalAsset();
    final batch = _firestore.batch();
    for (final term in all.take(10)) {
      final docRef = _namasteCodes.doc(term.code);
      batch.set(docRef, term.toJson());
    }
    await batch.commit();
  }
}
