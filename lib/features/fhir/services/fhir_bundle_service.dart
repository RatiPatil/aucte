/// AUCTE — FHIR Bundle Service.
library;

import 'package:uuid/uuid.dart';

import '../../mapping/models/mapping_result.dart';
import '../models/bundle_entry_model.dart';
import '../models/bundle_metadata_model.dart';
import '../models/fhir_bundle_model.dart';
import '../models/fhir_condition_model.dart';
import '../models/fhir_encounter_model.dart';
import '../repositories/fhir_repository.dart';
import 'fhir_service.dart';

class FhirBundleService {
  FhirBundleService({FhirRepository? repository})
      : _repository = repository ?? FhirRepository();

  final FhirRepository _repository;
  final _uuid = const Uuid();

  /// Assembles Patient, Practitioner, Encounter, and Condition into a single FHIR R4 Bundle.
  FhirBundleModel createBundle({
    required MappingResult mapping,
    required String practitionerName,
  }) {
    final bundleId = _uuid.v4();
    final now = DateTime.now();

    // 1. Generate core FHIR resources using the repository
    final patient = _repository.generatePatient();
    final practitioner = _repository.generatePractitioner(practitionerName);
    final encounter = _repository.generateEncounter(patient.id);

    final condition = _repository.generateCondition(
      subjectId: patient.id,
      encounterId: encounter.id,
      recorderId: practitioner.id,
      namasteCode: mapping.namaste.code,
      namasteDisplay: mapping.namaste.name,
      tm2Code: mapping.tm2?.code ?? 'N/A',
      tm2Display: mapping.tm2?.title ?? 'Not Mapped',
      icd11Code: mapping.icd11?.code ?? 'N/A',
      icd11Display: mapping.icd11?.title ?? 'Not Mapped',
    );

    // 2. Wrap each resource into a FHIR Bundle entry with URN UUID fullUrls
    final entries = [
      BundleEntryModel(
        fullUrl: 'urn:uuid:${patient.id}',
        resource: patient,
      ),
      BundleEntryModel(
        fullUrl: 'urn:uuid:${practitioner.id}',
        resource: practitioner,
      ),
      BundleEntryModel(
        fullUrl: 'urn:uuid:${encounter.id}',
        resource: encounter,
      ),
      BundleEntryModel(
        fullUrl: 'urn:uuid:${condition.id}',
        resource: condition,
      ),
    ];

    // 3. Create bundle metadata
    final metadata = BundleMetadataModel(
      bundleId: bundleId,
      timestamp: now,
      identifier: 'urn:uuid:$bundleId',
    );

    // 4. Return assembled FHIR Bundle Model
    return FhirBundleModel(
      id: bundleId,
      type: 'collection',
      timestamp: now,
      metadata: metadata,
      total: entries.length,
      entries: entries,
    );
  }

  /// Performs strict FHIR R4 structural and reference integrity validation.
  FhirValidationResult validateBundle(FhirBundleModel bundle) {
    if (bundle.toJson()['resourceType'] != 'Bundle') {
      return const FhirValidationResult(
        ValidationStatus.error,
        'Invalid FHIR structure: missing resourceType "Bundle".',
      );
    }

    if (bundle.type != 'collection') {
      return const FhirValidationResult(
        ValidationStatus.warning,
        'Non-standard bundle type. Expected "collection".',
      );
    }

    if (bundle.entries.isEmpty) {
      return const FhirValidationResult(
        ValidationStatus.error,
        'Bundle contains zero entries.',
      );
    }

    // Check duplicate IDs
    final ids = <String>{};
    for (final entry in bundle.entries) {
      final json = entry.resource.toJson();
      final id = json['id'] as String?;
      if (id != null && ids.contains(id)) {
        return FhirValidationResult(
          ValidationStatus.error,
          'Duplicate resource ID found in bundle entries: $id',
        );
      }
      if (id != null) ids.add(id);
    }

    // Collect entry resource types and IDs
    final entryResourceIds = <String, Set<String>>{};
    for (final entry in bundle.entries) {
      final json = entry.resource.toJson();
      final type = json['resourceType'] as String? ?? 'Unknown';
      final id = json['id'] as String? ?? '';
      entryResourceIds.putIfAbsent(type, () => {}).add(id);
    }

    // Validate presence of core resources
    final missingTypes = <String>[];
    for (final requiredType in ['Patient', 'Practitioner', 'Encounter', 'Condition']) {
      if (!entryResourceIds.containsKey(requiredType) ||
          entryResourceIds[requiredType]!.isEmpty) {
        missingTypes.add(requiredType);
      }
    }

    if (missingTypes.isNotEmpty) {
      return FhirValidationResult(
        ValidationStatus.error,
        'Missing required FHIR resources in bundle: ${missingTypes.join(', ')}',
      );
    }

    // Validate reference integrity for Encounter -> Patient
    for (final entry in bundle.entries) {
      if (entry.resource is FhirEncounterModel) {
        final enc = entry.resource as FhirEncounterModel;
        if (!entryResourceIds['Patient']!.contains(enc.subjectId)) {
          return FhirValidationResult(
            ValidationStatus.error,
            'Reference error: Encounter subject "${enc.subjectId}" not found in Bundle.',
          );
        }
      }

      // Validate reference integrity for Condition -> Patient, Encounter, Practitioner
      if (entry.resource is FhirConditionModel) {
        final cond = entry.resource as FhirConditionModel;
        if (!entryResourceIds['Patient']!.contains(cond.subjectId)) {
          return FhirValidationResult(
            ValidationStatus.error,
            'Reference error: Condition subject "${cond.subjectId}" not found in Bundle.',
          );
        }
        if (!entryResourceIds['Encounter']!.contains(cond.encounterId)) {
          return FhirValidationResult(
            ValidationStatus.error,
            'Reference error: Condition encounter "${cond.encounterId}" not found in Bundle.',
          );
        }
        if (!entryResourceIds['Practitioner']!.contains(cond.recorderId)) {
          return FhirValidationResult(
            ValidationStatus.error,
            'Reference error: Condition recorder "${cond.recorderId}" not found in Bundle.',
          );
        }

        if (cond.tm2Code == 'N/A' || cond.icd11Code == 'N/A') {
          return const FhirValidationResult(
            ValidationStatus.warning,
            'Valid FHIR R4 Bundle, but Condition coding has unmapped WHO TM2 or ICD-11 elements.',
          );
        }
      }
    }

    return const FhirValidationResult(
      ValidationStatus.valid,
      'Valid FHIR R4 Bundle package with full reference integrity.',
    );
  }
}
