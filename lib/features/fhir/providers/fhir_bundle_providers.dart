/// AUCTE — FHIR Bundle Providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/shared_prefs_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../mapping/providers/mapping_providers.dart';
import '../models/bundle_history_model.dart';
import '../models/fhir_bundle_model.dart';
import '../repositories/fhir_bundle_repository.dart';
import '../services/fhir_bundle_service.dart';
import '../services/fhir_service.dart';

final fhirBundleServiceProvider = Provider<FhirBundleService>((ref) {
  return FhirBundleService();
});

final fhirBundleRepositoryProvider = Provider<FhirBundleRepository>((ref) {
  final service = ref.watch(fhirBundleServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return FhirBundleRepository(
    bundleService: service,
    sharedPreferences: prefs,
  );
});

/// Seed token to trigger bundle regeneration
final bundleRegenerateTokenProvider = StateProvider.family<int, String>((ref, namasteCode) => 0);

/// Generates a FHIR R4 Bundle for a given NAMASTE code
final bundleProvider = FutureProvider.family<FhirBundleModel?, String>((ref, namasteCode) async {
  // Watching regenerate token causes bundle re-generation when incremented
  ref.watch(bundleRegenerateTokenProvider(namasteCode));

  final repo = ref.watch(fhirBundleRepositoryProvider);
  final user = await ref.watch(currentUserProvider.future);
  final mappingResult = await ref.watch(mappingResultProvider(namasteCode).future);

  if (mappingResult == null) return null;

  final practitionerName = user?.displayName ?? 'Dr. AYUSH Clinician';

  final bundle = repo.generateBundle(
    mapping: mappingResult,
    practitionerName: practitionerName,
  );

  // Validate and auto-save to history
  final validation = repo.validateBundle(bundle);
  await repo.saveBundleHistory(
    bundle,
    namasteCode: namasteCode,
    generatedBy: practitionerName,
    validationStatus: validation.status.name,
  );

  // Refresh history provider
  ref.read(bundleHistoryProvider.notifier).refreshHistory();

  return bundle;
});

/// Validates a given FHIR Bundle
final bundleValidationProvider = Provider.family<FhirValidationResult, FhirBundleModel>((ref, bundle) {
  final repo = ref.watch(fhirBundleRepositoryProvider);
  return repo.validateBundle(bundle);
});

/// Manages persistent FHIR Bundle History list
final bundleHistoryProvider = StateNotifierProvider<BundleHistoryNotifier, List<BundleHistoryModel>>((ref) {
  final repo = ref.watch(fhirBundleRepositoryProvider);
  return BundleHistoryNotifier(repo);
});

class BundleHistoryNotifier extends StateNotifier<List<BundleHistoryModel>> {
  BundleHistoryNotifier(this._repo) : super(_repo.getBundleHistory());

  final FhirBundleRepository _repo;

  void refreshHistory() {
    state = _repo.getBundleHistory();
  }

  Future<void> clearHistory() async {
    await _repo.clearBundleHistory();
    state = [];
  }
}

/// State provider for JSON Export format toggle (true = Pretty, false = Raw)
final bundleExportPrettyProvider = StateProvider<bool>((ref) => true);
