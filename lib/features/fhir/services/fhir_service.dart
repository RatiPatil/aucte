/// AUCTE — FHIR Service.
library;

import '../../mapping/models/mapping_result.dart';
import '../models/fhir_condition_model.dart';
import '../models/fhir_resource.dart';
import '../repositories/fhir_repository.dart';

enum ValidationStatus { valid, warning, error }

class FhirValidationResult {
  const FhirValidationResult(this.status, this.message);
  final ValidationStatus status;
  final String message;
}

class FhirService {
  FhirService({required FhirRepository repository}) : _repository = repository;

  final FhirRepository _repository;

  Future<FhirResource> generateResourceFromMapping(
    MappingResult mapping,
    String practitionerName,
    {FhirResourceType type = FhirResourceType.condition}
  ) async {
    // Generate related resources (simulating local FHIR generation)
    final patient = _repository.generatePatient();
    final practitioner = _repository.generatePractitioner(practitionerName);
    final encounter = _repository.generateEncounter(patient.id);

    switch (type) {
      case FhirResourceType.condition:
        return _repository.generateCondition(
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
      default:
        throw UnimplementedError('Generation for $type is not yet implemented.');
    }
  }

  FhirValidationResult validateResource(FhirResource resource) {
    if (resource is FhirConditionModel) {
      if (resource.namasteCode.isEmpty || resource.namasteDisplay.isEmpty) {
        return const FhirValidationResult(ValidationStatus.error, 'Missing primary NAMASTE coding.');
      }
      
      if (resource.tm2Code == 'N/A' || resource.icd11Code == 'N/A') {
        return const FhirValidationResult(ValidationStatus.warning, 'Mapping is incomplete (missing TM2 or ICD-11).');
      }

      return const FhirValidationResult(ValidationStatus.valid, 'Resource is a valid FHIR R4 Condition.');
    }

    return const FhirValidationResult(ValidationStatus.warning, 'Validation not implemented for this resource type.');
  }
}
