/// AUCTE — FHIR Encounter Model Placeholder.
library;

import 'fhir_resource.dart';

class FhirEncounterModel extends FhirResource {
  const FhirEncounterModel({
    required this.id,
    required this.status,
    required this.classCode,
    required this.subjectId,
  });

  final String id;
  final String status;
  final String classCode;
  final String subjectId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Encounter',
      'id': id,
      'status': status,
      'class': {
        'system': 'http://terminology.hl7.org/CodeSystem/v3-ActCode',
        'code': classCode,
      },
      'subject': {
        'reference': 'Patient/$subjectId',
      },
    };
  }
}
