import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/services/demo_api.dart';
import '../models/clinical_term_model.dart';
import 'terminology_repository.dart';

class LocalTerminologyRepository implements TerminologyRepository {
  LocalTerminologyRepository._();

  static final LocalTerminologyRepository instance =
      LocalTerminologyRepository._();

  List<ClinicalTermModel>? _cachedTerms;

  Future<List<ClinicalTermModel>> _loadFromAssets() async {
    if (_cachedTerms != null) {
      return _cachedTerms!;
    }

    if (DemoApi.configured) {
      try {
        return _cachedTerms = _parseTerms(await DemoApi.getTerms());
      } catch (_) {
        // The bundled CSV snapshot keeps terminology usable offline.
      }
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/namaste_demo.json',
      );
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;
      final List<dynamic> termsList = data['terms'] as List<dynamic>? ?? [];

      _cachedTerms = _parseTerms(termsList);

      return _cachedTerms!;
    } catch (e) {
      return [];
    }
  }

  List<ClinicalTermModel> _parseTerms(List<dynamic> terms) => terms
      .map(
        (item) =>
            ClinicalTermModel.fromMap(Map<String, dynamic>.from(item as Map)),
      )
      .toList();

  @override
  Future<List<ClinicalTermModel>> getAllTerms() async {
    return _loadFromAssets();
  }

  @override
  Future<List<ClinicalTermModel>> search(String query) async {
    final terms = await _loadFromAssets();
    if (query.trim().isEmpty) return terms;

    final q = query.trim().toLowerCase();
    return terms.where((t) {
      final namasteTerm = t.namasteTerm.toLowerCase().contains(q);
      final namasteCode = t.namasteCode.toLowerCase().contains(q);
      final tm2Title = t.tm2Title.toLowerCase().contains(q);
      final tm2Code = t.tm2Code.toLowerCase().contains(q);
      final bioTitle = t.biomedicineTitle.toLowerCase().contains(q);
      final bioCode = t.biomedicineCode.toLowerCase().contains(q);
      final desc = t.description.toLowerCase().contains(q);
      final sys = t.system.toLowerCase().contains(q);

      return t.whoTerm.toLowerCase().contains(q) ||
          namasteTerm ||
          namasteCode ||
          tm2Title ||
          tm2Code ||
          bioTitle ||
          bioCode ||
          desc ||
          sys;
    }).toList();
  }

  @override
  Future<List<ClinicalTermModel>> filterBySystem(String system) async {
    final terms = await _loadFromAssets();
    if (system.toLowerCase() == 'all') return terms;
    return terms
        .where((t) => t.system.toLowerCase() == system.toLowerCase())
        .toList();
  }

  @override
  Future<ClinicalTermModel?> getById(String id) async {
    final terms = await _loadFromAssets();
    for (final t in terms) {
      if (t.id == id) return t;
    }
    return null;
  }
}
