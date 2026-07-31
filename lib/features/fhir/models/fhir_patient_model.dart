/// AUCTE — FHIR Patient Model Placeholder.
library;

import 'fhir_resource.dart';

class FhirPatientModel extends FhirResource {
  const FhirPatientModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
  });

  final String id;
  final String name;
  final String gender;
  final String birthDate;

  @override
  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Patient',
      'id': id,
      'name': [
        {
          'use': 'official',
          'text': name,
        }
      ],
      'gender': gender,
      'birthDate': birthDate,
    };
  }
}
