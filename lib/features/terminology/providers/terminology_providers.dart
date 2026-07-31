/// AUCTE — Terminology Providers.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/shared_prefs_provider.dart';
import '../models/namaste_code_model.dart';
import '../repositories/terminology_repository.dart';
import '../services/terminology_service.dart';

final terminologyRepositoryProvider = Provider<ITerminologyRepository>((ref) {
  return FirestoreTerminologyRepository();
});

final terminologyServiceProvider = Provider<TerminologyService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final repo = ref.watch(terminologyRepositoryProvider);
  return TerminologyService(repository: repo, sharedPreferences: prefs);
});

final terminologySearchQueryProvider = StateProvider<String>((ref) => '');

/// Debounces the search query by 500ms
final _debouncedSearchQueryProvider = Provider<String>((ref) {
  final query = ref.watch(terminologySearchQueryProvider);
  return query; 
  // Riverpod 2.x doesn't have an easy debounce in providers directly without 
  // hooks or Future.delayed. We will debounce it by reading it with a delay 
  // inside the FutureProvider below.
});

final terminologySearchResultsProvider = FutureProvider.autoDispose<List<NamasteCodeModel>>((ref) async {
  final query = ref.watch(terminologySearchQueryProvider);
  
  if (query.trim().isEmpty) {
    return [];
  }

  // Debounce for 300ms
  // If the query changes, this provider will be disposed and recreated.
  // Delaying here achieves a simple debounce effect.
  var didDispose = false;
  ref.onDispose(() => didDispose = true);
  await Future.delayed(const Duration(milliseconds: 300));
  if (didDispose) {
    throw Exception('Cancelled');
  }

  final service = ref.watch(terminologyServiceProvider);
  return service.search(query);
});

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<NamasteCodeModel>>((ref) {
  final service = ref.watch(terminologyServiceProvider);
  return RecentSearchesNotifier(service);
});

class RecentSearchesNotifier extends StateNotifier<List<NamasteCodeModel>> {
  RecentSearchesNotifier(this._service) : super(_service.getRecentSearches());

  final TerminologyService _service;

  Future<void> addRecentSearch(NamasteCodeModel term) async {
    await _service.saveRecentSearch(term);
    state = _service.getRecentSearches();
  }
}

final popularTerminologyProvider = FutureProvider<List<NamasteCodeModel>>((ref) {
  final service = ref.watch(terminologyServiceProvider);
  return service.getPopularTerms();
});

final terminologyDetailProvider = FutureProvider.family<NamasteCodeModel?, String>((ref, code) {
  final service = ref.watch(terminologyServiceProvider);
  return service.getTerminologyByCode(code);
});
