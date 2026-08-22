import 'dart:convert';
import '../../encounters/models/encounter_model.dart';
import 'fhir_data_types.dart';

/// Standard FHIR R4 Encounter Resource Model.
class FhirEncounterModel {
  const FhirEncounterModel({
    required this.id,
    this.resourceType = 'Encounter',
    required this.status,
    required this.encounterClass,
    required this.subject,
    required this.participants,
    required this.period,
    required this.reasonCodes,
  });

  final String id;
  final String resourceType;
  final String status;
  final FhirCoding encounterClass;
  final FhirReference subject;
  final List<FhirReference> participants;
  final FhirPeriod period;
  final List<String> reasonCodes;

  Map<String, dynamic> toFhirResource() {
    return {
      "resourceType": "Encounter",
      "id": id,
      "status": status,
      "class": encounterClass.toMap(),
      "subject": subject.toMap(),
      "participant": participants
          .map((p) => {
                "individual": p.toMap(),
              })
          .toList(),
      "period": period.toMap(),
      "reasonCode": reasonCodes
          .map((r) => {
                "text": r,
              })
          .toList(),
      "meta": {
        "profile": [
          "https://nrces.in/ndhm/fhir/r4/StructureDefinition/Encounter",
        ],
      },
    };
  }

  factory FhirEncounterModel.fromEncounterModel({
    required EncounterModel encounter,
    required String patientName,
    required String practitionerName,
  }) {
    return FhirEncounterModel(
      id: encounter.id,
      status: encounter.status,
      encounterClass: const FhirCoding(
        system: "http://terminology.hl7.org/CodeSystem/v3-ActCode",
        code: "AMB",
        display: "ambulatory",
      ),
      subject: FhirReference(
        reference: "Patient/${encounter.patientId}",
        display: patientName,
        type: "Patient",
      ),
      participants: [
        FhirReference(
          reference: "Practitioner/${encounter.practitionerId}",
          display: practitionerName,
          type: "Practitioner",
        ),
      ],
      period: FhirPeriod(
        start: encounter.encounterDate,
      ),
      reasonCodes: [
        encounter.chiefComplaint,
        if (encounter.clinicalNotes.isNotEmpty) encounter.clinicalNotes,
      ],
    );
  }

  factory FhirEncounterModel.fromFhirMap(Map<String, dynamic> map) {
    final status = map['status']?.toString() ?? 'completed';
    final classMap = map['class'] as Map<String, dynamic>? ?? {};
    final encounterClass = FhirCoding.fromMap(classMap);

    final subjectMap = map['subject'] as Map<String, dynamic>? ?? {};
    final subject = FhirReference.fromMap(subjectMap);

    final participants = <FhirReference>[];
    final parts = map['participant'] as List<dynamic>? ?? [];
    for (final p in parts) {
      if (p is Map<String, dynamic> && p.containsKey('individual')) {
        participants.add(FhirReference.fromMap(
          Map<String, dynamic>.from(p['individual'] as Map),
        ));
      }
    }

    final periodMap = map['period'] as Map<String, dynamic>? ?? {};
    final period = FhirPeriod.fromMap(periodMap);

    final reasons = <String>[];
    final reasonList = map['reasonCode'] as List<dynamic>? ?? [];
    for (final r in reasonList) {
      if (r is Map<String, dynamic> && r.containsKey('text')) {
        reasons.add(r['text'].toString());
      }
    }

    return FhirEncounterModel(
      id: map['id']?.toString() ?? '',
      status: status,
      encounterClass: encounterClass,
      subject: subject,
      participants: participants,
      period: period,
      reasonCodes: reasons,
    );
  }

  String toJsonString() => jsonEncode(toFhirResource());
}
