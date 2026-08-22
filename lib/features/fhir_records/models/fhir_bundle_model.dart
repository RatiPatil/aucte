import 'dart:convert';
import 'fhir_condition_model.dart';
import 'fhir_consent_model.dart';
import 'fhir_encounter_model.dart';
import 'fhir_observation_model.dart';
import 'fhir_patient_model.dart';
import 'fhir_practitioner_model.dart';

/// Complete Standard FHIR R4 Bundle Document Resource Model for AUCTE.
class FhirBundleModel {
  const FhirBundleModel({
    required this.id,
    this.resourceType = 'Bundle',
    this.type = 'document',
    required this.timestamp,
    required this.profileUrl,
    required this.patient,
    required this.practitioner,
    required this.encounter,
    required this.conditions,
    this.consent,
    this.observations = const [],
    this.rawEntries = const [],
  });

  final String id;
  final String resourceType;
  final String type;
  final DateTime timestamp;
  final String profileUrl;
  final FhirPatientModel patient;
  final FhirPractitionerModel practitioner;
  final FhirEncounterModel encounter;
  final List<FhirConditionModel> conditions;
  final FhirConsentModel? consent;
  final List<FhirObservationModel> observations;
  final List<Map<String, dynamic>> rawEntries;

  /// Number of total resources bundled
  int get totalResources {
    int count = 3 + conditions.length + (consent != null ? 1 : 0) + observations.length;
    return count;
  }

  /// Check whether all diagnoses have valid dual-coded concepts
  bool get isDualCoded {
    if (conditions.isEmpty) return false;
    return conditions.every((c) =>
        c.term.tm2Code.isNotEmpty && c.term.biomedicineCode.isNotEmpty);
  }

  /// Generate compliant FHIR R4 Bundle Map
  Map<String, dynamic> toFhirResource() {
    final List<Map<String, dynamic>> entries = [];

    // 1. Patient Entry
    entries.add({
      "fullUrl": "urn:uuid:${patient.id}",
      "resource": patient.toFhirResource(),
    });

    // 2. Practitioner Entry
    entries.add({
      "fullUrl": "urn:uuid:${practitioner.id}",
      "resource": practitioner.toFhirResource(),
    });

    // 3. Encounter Entry
    entries.add({
      "fullUrl": "urn:uuid:${encounter.id}",
      "resource": encounter.toFhirResource(),
    });

    // 4. Condition Entries (Dual-Coded)
    for (final cond in conditions) {
      entries.add({
        "fullUrl": "urn:uuid:${cond.id}",
        "resource": cond.toFhirResource(),
      });
    }

    // 5. Consent Entry if present
    if (consent != null) {
      entries.add({
        "fullUrl": "urn:uuid:${consent!.id}",
        "resource": consent!.toFhirResource(),
      });
    }

    // 6. Observation Entries if present
    for (final obs in observations) {
      entries.add({
        "fullUrl": "urn:uuid:${obs.id}",
        "resource": obs.toFhirResource(),
      });
    }

    return {
      "resourceType": "Bundle",
      "id": id,
      "type": type,
      "timestamp": timestamp.toIso8601String(),
      "meta": {
        "profile": [profileUrl],
        "versionId": "1",
        "lastUpdated": DateTime.now().toIso8601String(),
      },
      "entry": entries,
    };
  }

  /// Formatted indented JSON String
  String toFormattedJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toFhirResource());
  }

  /// Construct typed model from standard FHIR Bundle JSON Map
  factory FhirBundleModel.fromFhirMap(Map<String, dynamic> map) {
    final id = map['id']?.toString() ?? 'auc-bundle-generic';
    final type = map['type']?.toString() ?? 'document';
    final timestamp = DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
        DateTime.now();

    String profile =
        'https://aucte.ayush.gov.in/fhir/StructureDefinition/aucte-clinical-document';
    final meta = map['meta'] as Map<String, dynamic>?;
    final profiles = meta?['profile'] as List<dynamic>? ?? [];
    if (profiles.isNotEmpty) {
      profile = profiles.first.toString();
    }

    final entries = map['entry'] as List<dynamic>? ?? [];

    FhirPatientModel? patient;
    FhirPractitionerModel? practitioner;
    FhirEncounterModel? encounter;
    final conditions = <FhirConditionModel>[];
    FhirConsentModel? consent;
    final observations = <FhirObservationModel>[];

    for (final e in entries) {
      if (e is Map<String, dynamic> && e.containsKey('resource')) {
        final res = e['resource'] as Map<String, dynamic>;
        final resType = res['resourceType']?.toString() ?? '';

        switch (resType) {
          case 'Patient':
            patient = FhirPatientModel.fromFhirMap(res);
            break;
          case 'Practitioner':
            practitioner = FhirPractitionerModel.fromFhirMap(res);
            break;
          case 'Encounter':
            encounter = FhirEncounterModel.fromFhirMap(res);
            break;
          case 'Condition':
            conditions.add(FhirConditionModel.fromFhirMap(res));
            break;
          case 'Consent':
            consent = FhirConsentModel.fromFhirMap(res);
            break;
          case 'Observation':
            observations.add(FhirObservationModel.fromFhirMap(res));
            break;
        }
      }
    }

    // Provide safe defaults if required parts are absent
    final safePatient = patient ??
        FhirPatientModel(
          id: 'patient-fallback',
          identifiers: [],
          name: 'Patient',
          gender: 'other',
          birthDate: DateTime(1990, 1, 1),
          telecom: '',
          address: '',
        );

    final safePractitioner = practitioner ??
        const FhirPractitionerModel(
          id: 'practitioner-fallback',
          identifiers: [],
          name: 'Dr. AYUSH Specialist',
          qualification: 'AYUSH Specialist',
          ayushSystem: 'Ayurveda',
          institution: 'All India Institute of Ayurveda',
        );

    final safeEncounter = encounter ??
        FhirEncounterModel.fromFhirMap({
          "id": "enc-fallback",
          "status": "completed",
          "class": {"code": "AMB", "display": "ambulatory"},
          "subject": {"reference": "Patient/${safePatient.id}"},
          "participant": [],
          "period": {"start": timestamp.toIso8601String()},
          "reasonCode": [],
        });

    return FhirBundleModel(
      id: id,
      type: type,
      timestamp: timestamp,
      profileUrl: profile,
      patient: safePatient,
      practitioner: safePractitioner,
      encounter: safeEncounter,
      conditions: conditions,
      consent: consent,
      observations: observations,
      rawEntries: entries.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }

  factory FhirBundleModel.fromJson(String source) {
    return FhirBundleModel.fromFhirMap(
      Map<String, dynamic>.from(jsonDecode(source) as Map),
    );
  }
}
