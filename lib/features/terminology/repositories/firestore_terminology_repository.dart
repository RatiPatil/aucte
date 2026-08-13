import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/clinical_term_model.dart';
import 'local_terminology_repository.dart';
import 'terminology_repository.dart';

/// Firestore-backed terminology repository.
/// Seeds terminologies/ collection from local JSON on first run (if empty).
/// Falls back to local asset data on any Firestore error.
class FirestoreTerminologyRepository implements TerminologyRepository {
  FirestoreTerminologyRepository._();

  static final FirestoreTerminologyRepository instance =
      FirestoreTerminologyRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalTerminologyRepository _localRepo =
      LocalTerminologyRepository.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('terminologies');

  List<ClinicalTermModel>? _cache;

  Future<List<ClinicalTermModel>> _loadAll() async {
    if (_cache != null) return _cache!;

    try {
      final snapshot = await _collection.get();

      if (snapshot.docs.isEmpty) {
        // First run: seed Firestore from local JSON
        final localTerms = await _localRepo.getAllTerms();
        await _seedFirestore(localTerms);
        _cache = localTerms;
        return _cache!;
      }

      _cache = snapshot.docs
          .map((doc) => ClinicalTermModel.fromMap(doc.data()))
          .toList();
      return _cache!;
    } catch (e) {
      debugPrint('Firestore terminology error, using local: $e');
      final localTerms = await _localRepo.getAllTerms();
      _cache = localTerms;
      return _cache!;
    }
  }

  Future<void> _seedFirestore(List<ClinicalTermModel> terms) async {
    final batch = _firestore.batch();
    for (final term in terms) {
      final docRef = _collection.doc(term.id);
      batch.set(docRef, term.toMap());
    }
    await batch.commit();
    debugPrint('Seeded ${terms.length} terminology records to Firestore.');
  }

  @override
  Future<List<ClinicalTermModel>> getAllTerms() => _loadAll();

  @override
  Future<List<ClinicalTermModel>> search(String query) async {
    final terms = await _loadAll();
    if (query.trim().isEmpty) return terms;

    final q = query.trim().toLowerCase();
    return terms.where((t) {
      return t.namasteTerm.toLowerCase().contains(q) ||
          t.namasteCode.toLowerCase().contains(q) ||
          t.tm2Title.toLowerCase().contains(q) ||
          t.tm2Code.toLowerCase().contains(q) ||
          t.biomedicineTitle.toLowerCase().contains(q) ||
          t.biomedicineCode.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.system.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<List<ClinicalTermModel>> filterBySystem(String system) async {
    final terms = await _loadAll();
    if (system.toLowerCase() == 'all') return terms;
    return terms
        .where((t) => t.system.toLowerCase() == system.toLowerCase())
        .toList();
  }

  @override
  Future<ClinicalTermModel?> getById(String id) async {
    final terms = await _loadAll();
    for (final t in terms) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Clears in-memory cache (forces reload on next call).
  void invalidateCache() => _cache = null;
}
