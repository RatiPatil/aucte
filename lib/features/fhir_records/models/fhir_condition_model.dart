import 'dart:convert';

import '../../terminology/models/clinical_term_model.dart';

/// Standard FHIR R4 Condition Resource Model featuring AUCTE Dual Coding.
/// Represents a clinical condition encoded concurrently in:
/// 1. NAMASTE Traditional Coding System
/// 2. WHO ICD-11 TM2 (Traditional Medicine Module 2)
/// 3. WHO ICD-11 Biomedicine Classification
class FhirConditionModel {
  const FhirConditionModel({
    required this.id,
    this.resourceType = 'Condition',
    this.clinicalStatus = 'active',
    this.verificationStatus = 'confirmed',
    required this.subjectId,
    required this.encounterId,
    required this.recordedDate,
    required this.term,
    this.notes,
  });

  final String id;
  final String resourceType;
  final String clinicalStatus;
  final String verificationStatus;
  final String subjectId;
  final String encounterId;
  final DateTime recordedDate;
  final ClinicalTermModel term;
  final String? notes;

  static const _demoRoot = 'https://aucte.example/fhir/CodeSystem/demo-';
  static const _demoVersion = 'demo-2.0';

  bool get _synthetic => term.isDemo || term.namasteCode.startsWith('DEMO-');

  Map<String, dynamic> toFhirResource() {
    return {
      "resourceType": "Condition",
      "id": id,
      "clinicalStatus": {
        "coding": [
          {
            "system":
                "http://terminology.hl7.org/CodeSystem/condition-clinical",
            "code": clinicalStatus,
            "display": clinicalStatus.isNotEmpty
                ? clinicalStatus[0].toUpperCase() + clinicalStatus.substring(1)
                : 'Active',
          },
        ],
      },
      "verificationStatus": {
        "coding": [
          {
            "system":
                "http://terminology.hl7.org/CodeSystem/condition-ver-status",
            "code": verificationStatus,
            "display": verificationStatus.isNotEmpty
                ? verificationStatus[0].toUpperCase() +
                      verificationStatus.substring(1)
                : 'Confirmed',
          },
        ],
      },
      "category": [
        {
          "coding": [
            {
              "system":
                  "http://terminology.hl7.org/CodeSystem/condition-category",
              "code": "problem-list-item",
              "display": "Problem List Item",
            },
          ],
        },
      ],
      "code": {
        "coding": [
          // 1. Primary Traditional AYUSH Concept (NAMASTE)
          {
            "system": _synthetic
                ? "${_demoRoot}namaste"
                : "https://aucte.ayush.gov.in/fhir/namaste/${term.system.toLowerCase()}",
            if (_synthetic) "version": _demoVersion,
            "code": term.namasteCode,
            "display": term.namasteTerm,
            "userSelected": true,
          },
          if (term.tm2Code.isNotEmpty)
            {
              "system": _synthetic
                  ? "${_demoRoot}tm2"
                  : "http://id.who.int/icd/release/11/mms/tm2",
              if (_synthetic) "version": _demoVersion,
              "code": term.tm2Code,
              "display": term.tm2Title,
            },
          if (term.biomedicineCode.isNotEmpty)
            {
              "system": _synthetic
                  ? "${_demoRoot}biomedicine"
                  : "http://id.who.int/icd/release/11/mms/biomedicine",
              if (_synthetic) "version": _demoVersion,
              "code": term.biomedicineCode,
              "display": term.biomedicineTitle,
            },
        ],
        "text": "${term.namasteTerm} [${term.system}]",
      },
      "subject": {"reference": "Patient/$subjectId", "type": "Patient"},
      "encounter": {"reference": "Encounter/$encounterId", "type": "Encounter"},
      "recordedDate": recordedDate.toUtc().toIso8601String(),
      if (notes != null && notes!.isNotEmpty)
        "note": [
          {"text": notes},
        ],
      "meta": {
        "versionId": "1",

        "tag": [
          {
            "system": "https://aucte.ayush.gov.in/tags",
            "code": "dual-coded-condition",
            "display": "AUCTE Dual Coded Condition",
          },
        ],
      },
    };
  }

  /// Create a standalone Condition resource from a ClinicalTermModel (e.g. for previewing in search/mapping)
  factory FhirConditionModel.fromClinicalTerm(
    ClinicalTermModel term, {
    String? subjectId,
    String? encounterId,
  }) {
    return FhirConditionModel(
      id: "cond-${term.namasteCode.replaceAll(' ', '_').toLowerCase()}",
      clinicalStatus: "active",
      verificationStatus: "confirmed",
      subjectId: subjectId ?? "DEMO-PATIENT-001",
      encounterId: encounterId ?? "DEMO-ENC-001",
      recordedDate: DateTime.now(),
      term: term,
    );
  }

  factory FhirConditionModel.fromFhirMap(Map<String, dynamic> map) {
    final id = map['id']?.toString() ?? '';

    // clinical status
    String clinStat = 'active';
    final cs = map['clinicalStatus'] as Map<String, dynamic>?;
    final csCodings = cs?['coding'] as List<dynamic>? ?? [];
    if (csCodings.isNotEmpty) {
      clinStat = csCodings.first['code']?.toString() ?? 'active';
    }

    // verification status
    String verStat = 'confirmed';
    final vs = map['verificationStatus'] as Map<String, dynamic>?;
    final vsCodings = vs?['coding'] as List<dynamic>? ?? [];
    if (vsCodings.isNotEmpty) {
      verStat = vsCodings.first['code']?.toString() ?? 'confirmed';
    }

    // subject & encounter references
    String sId = '';
    final sub = map['subject'] as Map<String, dynamic>?;
    final subRef = sub?['reference']?.toString() ?? '';
    if (subRef.contains('/')) {
      sId = subRef.split('/').last;
    } else {
      sId = subRef;
    }

    String eId = '';
    final enc = map['encounter'] as Map<String, dynamic>?;
    final encRef = enc?['reference']?.toString() ?? '';
    if (encRef.contains('/')) {
      eId = encRef.split('/').last;
    } else {
      eId = encRef;
    }

    final recDate =
        DateTime.tryParse(map['recordedDate']?.toString() ?? '') ??
        DateTime.now();

    // Parse dual codings
    final codeMap = map['code'] as Map<String, dynamic>? ?? {};
    final codings = codeMap['coding'] as List<dynamic>? ?? [];

    String namasteCode = '';
    String namasteTerm = '';
    String system = 'Ayurveda';
    String tm2Code = '';
    String tm2Title = '';
    String bioCode = '';
    String bioTitle = '';

    for (final c in codings) {
      if (c is Map<String, dynamic>) {
        final sys = c['system']?.toString() ?? '';
        final code = c['code']?.toString() ?? '';
        final display = c['display']?.toString() ?? '';

        if (sys.contains('namaste')) {
          namasteCode = code;
          namasteTerm = display;
          if (sys.contains('siddha')) {
            system = 'Siddha';
          } else if (sys.contains('unani')) {
            system = 'Unani';
          } else if (sys.contains('homeopathy')) {
            system = 'Homeopathy';
          } else {
            system = 'Ayurveda';
          }
        } else if (sys.contains('tm2')) {
          tm2Code = code;
          tm2Title = display;
        } else if (sys.contains('biomedicine')) {
          bioCode = code;
          bioTitle = display;
        }
      }
    }

    final synthetic = namasteCode.startsWith('DEMO-');
    if (namasteCode.startsWith('DEMO-NAM-SID-')) system = 'Siddha';
    if (namasteCode.startsWith('DEMO-NAM-UNA-')) system = 'Unani';

    if (namasteTerm.isEmpty && codeMap.containsKey('text')) {
      namasteTerm = codeMap['text'].toString();
    }

    final term = ClinicalTermModel(
      id: id,
      namasteCode: namasteCode.isNotEmpty ? namasteCode : 'NAM-DEMO',
      namasteTerm: namasteTerm.isNotEmpty ? namasteTerm : 'Clinical Condition',
      system: system,
      description: 'Dual coded FHIR Condition Resource',
      tm2Code: tm2Code,
      tm2Title: tm2Title,
      biomedicineCode: bioCode,
      biomedicineTitle: bioTitle,
      mappingType: 'dual-coded',
      mappingConfidence: synthetic ? 0 : 0.95,
      source: 'AUCTE FHIR R4 Engine',
      isDemo: synthetic,
    );

    return FhirConditionModel(
      id: id,
      clinicalStatus: clinStat,
      verificationStatus: verStat,
      subjectId: sId,
      encounterId: eId,
      recordedDate: recDate,
      term: term,
    );
  }

  String toJsonString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toFhirResource());
  }
}
