import 'dart:convert';
import 'fhir_data_types.dart';

/// Standard FHIR R4 Observation Resource Model for AYUSH clinical examinations (Prakriti, Agni, Vitals).
class FhirObservationModel {
  const FhirObservationModel({
    required this.id,
    this.resourceType = 'Observation',
    this.status = 'final',
    required this.code,
    required this.subject,
    required this.encounter,
    required this.effectiveDateTime,
    this.valueString,
    this.valueQuantity,
    this.unit,
  });

  final String id;
  final String resourceType;
  final String status;
  final FhirCodeableConcept code;
  final FhirReference subject;
  final FhirReference encounter;
  final DateTime effectiveDateTime;
  final String? valueString;
  final double? valueQuantity;
  final String? unit;

  Map<String, dynamic> toFhirResource() {
    return {
      "resourceType": "Observation",
      "id": id,
      "status": status,
      "category": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/observation-category",
              "code": "exam",
              "display": "Exam",
            },
          ],
        },
      ],
      "code": code.toMap(),
      "subject": subject.toMap(),
      "encounter": encounter.toMap(),
      "effectiveDateTime": effectiveDateTime.toIso8601String(),
      if (valueString != null) "valueString": valueString,
      if (valueQuantity != null)
        "valueQuantity": {
          "value": valueQuantity,
          if (unit != null) "unit": unit,
          "system": "http://unitsofmeasure.org",
        },
      "meta": {
        "profile": [
          "https://nrces.in/ndhm/fhir/r4/StructureDefinition/Observation",
        ],
      },
    };
  }

  factory FhirObservationModel.fromFhirMap(Map<String, dynamic> map) {
    final codeMap = map['code'] as Map<String, dynamic>? ?? {};
    final code = FhirCodeableConcept.fromMap(codeMap);

    final subMap = map['subject'] as Map<String, dynamic>? ?? {};
    final subject = FhirReference.fromMap(subMap);

    final encMap = map['encounter'] as Map<String, dynamic>? ?? {};
    final encounter = FhirReference.fromMap(encMap);

    final valQtyMap = map['valueQuantity'] as Map<String, dynamic>?;
    final valQty = (valQtyMap?['value'] as num?)?.toDouble();
    final unit = valQtyMap?['unit']?.toString();

    return FhirObservationModel(
      id: map['id']?.toString() ?? '',
      status: map['status']?.toString() ?? 'final',
      code: code,
      subject: subject,
      encounter: encounter,
      effectiveDateTime: DateTime.tryParse(map['effectiveDateTime']?.toString() ?? '') ?? DateTime.now(),
      valueString: map['valueString']?.toString(),
      valueQuantity: valQty,
      unit: unit,
    );
  }

  String toJsonString() => jsonEncode(toFhirResource());
}
