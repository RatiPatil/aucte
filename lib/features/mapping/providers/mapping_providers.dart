/// AUCTE — Mapping Providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../terminology/providers/terminology_providers.dart';
import '../models/mapping_result.dart';
import '../repositories/mapping_repository.dart';
import '../services/mapping_service.dart';

final mappingRepositoryProvider = Provider<IMappingRepository>((ref) {
  return FirestoreMappingRepository();
});

final mappingServiceProvider = Provider<MappingService>((ref) {
  final mappingRepo = ref.watch(mappingRepositoryProvider);
  final terminologyRepo = ref.watch(terminologyRepositoryProvider);
  return MappingService(
    mappingRepository: mappingRepo,
    terminologyRepository: terminologyRepo,
  );
});

final mappingResultProvider = FutureProvider.family<MappingResult?, String>((ref, namasteCode) async {
  final service = ref.watch(mappingServiceProvider);
  return service.getMappingResult(namasteCode);
});
