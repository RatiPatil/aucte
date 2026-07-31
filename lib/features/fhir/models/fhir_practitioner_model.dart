/// AUCTE — FHIR Practitioner Model Placeholder.
library;

import 'fhir_resource.dart';

class FhirPractitionerModel extends FhirResource {
  const FhirPractitionerModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Practitioner',
      'id': id,
      'name': [
        {
          'use': 'official',
          'text': name,
        }
      ],
    };
  }
}
