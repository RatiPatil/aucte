/// AUCTE — FHIR Providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_provider.dart';
import '../../mapping/providers/mapping_providers.dart';
import '../models/fhir_resource.dart';
import '../repositories/fhir_repository.dart';
import '../services/fhir_service.dart';

final fhirRepositoryProvider = Provider<FhirRepository>((ref) {
  return FhirRepository();
});

final fhirServiceProvider = Provider<FhirService>((ref) {
  final repo = ref.watch(fhirRepositoryProvider);
  return FhirService(repository: repo);
});

final fhirResourceProvider = FutureProvider.family<FhirResource?, String>((ref, namasteCode) async {
  final service = ref.watch(fhirServiceProvider);
  final user = await ref.watch(currentUserProvider.future);
  final mappingResult = await ref.watch(mappingResultProvider(namasteCode).future);
  
  if (mappingResult == null) return null;
  
  return service.generateResourceFromMapping(mappingResult, user?.displayName ?? 'Unknown Doctor');
});

final fhirValidationProvider = Provider.family<FhirValidationResult, FhirResource>((ref, resource) {
  final service = ref.watch(fhirServiceProvider);
  return service.validateResource(resource);
});
