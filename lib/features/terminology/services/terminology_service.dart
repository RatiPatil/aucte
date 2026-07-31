/// AUCTE — Terminology Service.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/namaste_code_model.dart';
import '../repositories/terminology_repository.dart';

class TerminologyService {
  TerminologyService({
    required ITerminologyRepository repository,
    required SharedPreferences sharedPreferences,
  })  : _repository = repository,
        _prefs = sharedPreferences;

  final ITerminologyRepository _repository;
  final SharedPreferences _prefs;

  static const String _recentSearchesKey = 'recent_namaste_searches';
  static const int _maxRecentSearches = 10;

  Future<List<NamasteCodeModel>> search(String query) {
    // Terminology repository handles trimming and lowering case
    return _repository.searchNamaste(query);
  }

  Future<NamasteCodeModel?> getTerminologyByCode(String code) {
    return _repository.getTerminologyByCode(code);
  }

  Future<List<NamasteCodeModel>> getPopularTerms() {
    return _repository.getPopularTerms();
  }

  /// Gets recent searches from SharedPreferences
  List<NamasteCodeModel> getRecentSearches() {
    final List<String> recentJson = _prefs.getStringList(_recentSearchesKey) ?? [];
    
    return recentJson.map((jsonStr) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return NamasteCodeModel.fromJson(map);
      } catch (e) {
        return null;
      }
    }).whereType<NamasteCodeModel>().toList();
  }

  /// Saves a selected terminology to recent searches
  Future<void> saveRecentSearch(NamasteCodeModel term) async {
    final List<NamasteCodeModel> currentRecent = getRecentSearches();

    // Remove if already exists so we can move it to the top
    currentRecent.removeWhere((element) => element.code == term.code);
    
    // Add to the top
    currentRecent.insert(0, term);

    // Keep only top 10
    if (currentRecent.length > _maxRecentSearches) {
      currentRecent.removeLast();
    }

    final List<String> newRecentJson = currentRecent
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await _prefs.setStringList(_recentSearchesKey, newRecentJson);
  }
}
