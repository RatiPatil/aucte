/// AUCTE — Dataset Loader Providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/shared_prefs_provider.dart';
import '../services/dataset_loader_service.dart';

final datasetLoaderServiceProvider = Provider<DatasetLoaderService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DatasetLoaderService(sharedPreferences: prefs);
});

final datasetValidationProvider = FutureProvider<DatasetValidationReport>((ref) async {
  final loader = ref.watch(datasetLoaderServiceProvider);
  return loader.validateDatasets();
});

class DatasetImportState {
  const DatasetImportState({
    this.isImporting = false,
    this.progress = 0,
    this.status = '',
    this.isCompleted = false,
    this.error,
  });

  final bool isImporting;
  final int progress;
  final String status;
  final bool isCompleted;
  final String? error;

  DatasetImportState copyWith({
    bool? isImporting,
    int? progress,
    String? status,
    bool? isCompleted,
    String? error,
  }) {
    return DatasetImportState(
      isImporting: isImporting ?? this.isImporting,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}

final datasetImportNotifierProvider =
    StateNotifierProvider<DatasetImportNotifier, DatasetImportState>((ref) {
  final loader = ref.watch(datasetLoaderServiceProvider);
  return DatasetImportNotifier(loader);
});

class DatasetImportNotifier extends StateNotifier<DatasetImportState> {
  DatasetImportNotifier(this._loader) : super(const DatasetImportState());

  final DatasetLoaderService _loader;

  Future<void> runBootstrapImport({bool force = false}) async {
    if (_loader.isImported && !force) {
      state = state.copyWith(
        isImporting: false,
        isCompleted: true,
        progress: 100,
        status: 'Datasets already loaded.',
      );
      return;
    }

    state = state.copyWith(
      isImporting: true,
      progress: 0,
      status: 'Starting offline terminology import...',
    );

    final success = await _loader.bootstrapImport(
      forceReimport: force,
      onProgress: (imported, total, message) {
        state = state.copyWith(
          progress: imported,
          status: message,
        );
      },
    );

    if (success) {
      state = state.copyWith(
        isImporting: false,
        isCompleted: true,
        progress: 100,
        status: 'Import completed successfully!',
      );
    } else {
      state = state.copyWith(
        isImporting: false,
        isCompleted: false,
        error: 'Failed to import terminology datasets.',
      );
    }
  }
}
