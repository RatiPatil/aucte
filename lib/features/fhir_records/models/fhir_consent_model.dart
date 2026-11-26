import 'dart:convert';
import '../../consent/models/consent_model.dart';
import 'fhir_data_types.dart';

/// Standard FHIR R4 Consent Resource Model compliant with ABDM/NDHM principles.
class FhirConsentModel {
  const FhirConsentModel({
    required this.id,
    this.resourceType = 'Consent',
    required this.status,
    required this.scope,
    required this.category,
    required this.patient,
    required this.dateTime,
    required this.purposeText,
    this.version = '1.0',
  });

  final String id;
  final String resourceType;
  final String status;
  final FhirCodeableConcept scope;
  final FhirCodeableConcept category;
  final FhirReference patient;
  final DateTime dateTime;
  final String purposeText;
  final String version;

  Map<String, dynamic> toFhirResource() {
    return {
      "resourceType": "Consent",
      "id": id,
      "status": status,
      "scope": scope.toMap(),
      "category": [category.toMap()],
      "patient": patient.toMap(),
      "dateTime": dateTime.toUtc().toIso8601String(),
      "policyRule": {
        "text": purposeText,
      },
      "meta": {
        "versionId": version,
      },
    };
  }

  factory FhirConsentModel.fromConsentModel({
    required ConsentModel consent,
    required String patientName,
  }) {
    return FhirConsentModel(
      id: consent.id,
      status: consent.status == 'granted' ? 'active' : 'inactive',
      scope: const FhirCodeableConcept(
        coding: [
          FhirCoding(
            system: "http://terminology.hl7.org/CodeSystem/consentscope",
            code: "patient-privacy",
            display: "Patient Privacy",
          ),
        ],
      ),
      category: const FhirCodeableConcept(
        coding: [
          FhirCoding(
            system: "http://terminology.hl7.org/CodeSystem/consentcategorycodes",
            code: "acd",
            display: "Advance Care Directive",
          ),
        ],
      ),
      patient: FhirReference(
        reference: "Patient/${consent.patientId}",
        display: patientName,
        type: "Patient",
      ),
      dateTime: consent.grantedAt,
      purposeText: consent.purpose,
      version: consent.version,
    );
  }

  factory FhirConsentModel.fromFhirMap(Map<String, dynamic> map) {
    final scopeMap = map['scope'] as Map<String, dynamic>? ?? {};
    final scope = FhirCodeableConcept.fromMap(scopeMap);

    final cats = map['category'] as List<dynamic>? ?? [];
    final category = cats.isNotEmpty
        ? FhirCodeableConcept.fromMap(Map<String, dynamic>.from(cats.first as Map))
        : const FhirCodeableConcept(coding: []);

    final patientMap = map['patient'] as Map<String, dynamic>? ?? {};
    final patient = FhirReference.fromMap(patientMap);

    final prMap = map['policyRule'] as Map<String, dynamic>? ?? {};
    final purpose = prMap['text']?.toString() ?? 'Clinical Documentation';

    return FhirConsentModel(
      id: map['id']?.toString() ?? '',
      status: map['status']?.toString() ?? 'active',
      scope: scope,
      category: category,
      patient: patient,
      dateTime: DateTime.tryParse(map['dateTime']?.toString() ?? '') ?? DateTime.now(),
      purposeText: purpose,
      version: (map['meta'] as Map?)?['versionId']?.toString() ?? '1.0',
    );
  }

  String toJsonString() => jsonEncode(toFhirResource());
}
