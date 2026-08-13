import 'dart:convert';
import '../../terminology/models/clinical_term_model.dart';

class FhirConditionModel {
  const FhirConditionModel({
    required this.resourceType,
    required this.id,
    required this.clinicalStatus,
    required this.verificationStatus,
    required this.subjectId,
    required this.encounterId,
    required this.recordedDate,
    required this.term,
  });

  final String resourceType;
  final String id;
  final String clinicalStatus;
  final String verificationStatus;
  final String subjectId;
  final String encounterId;
  final DateTime recordedDate;
  final ClinicalTermModel term;

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
            "display":
                clinicalStatus[0].toUpperCase() + clinicalStatus.substring(1),
          },
        ],
      },
      "verificationStatus": {
        "coding": [
          {
            "system":
                "http://terminology.hl7.org/CodeSystem/condition-ver-status",
            "code": verificationStatus,
            "display":
                verificationStatus[0].toUpperCase() +
                verificationStatus.substring(1),
          },
        ],
      },
      "category": [
        {
          "coding": [
            {
              "system":
                  "http://terminology.hl7.org/CodeSystem/condition-category",
              "code": "encounter-diagnosis",
              "display": "Encounter Diagnosis",
            },
          ],
        },
      ],
      "code": {
        "coding": [
          {
            "system":
                "https://aucte.ayush.gov.in/fhir/namaste/${term.system.toLowerCase()}",
            "code": term.namasteCode,
            "display": term.namasteTerm,
          },
          {
            "system": "http://id.who.int/icd/release/11/mms/tm2",
            "code": term.tm2Code,
            "display": term.tm2Title,
          },
          {
            "system": "http://id.who.int/icd/release/11/mms/biomedicine",
            "code": term.biomedicineCode,
            "display": term.biomedicineTitle,
          },
        ],
        "text": "${term.namasteTerm} [${term.system}]",
      },
      "subject": {"reference": "Patient/$subjectId"},
      "encounter": {"reference": "Encounter/$encounterId"},
      "recordedDate": recordedDate.toIso8601String(),
      "meta": {
        "versionId": "1",
        "lastUpdated": DateTime.now().toIso8601String(),
        "tag": [
          {
            "system": "https://aucte.ayush.gov.in/tags",
            "code": "sih-demo-fhir-r4",
            "display": "AUCTE SIH Prototype FHIR R4",
          },
        ],
      },
    };
  }

  String toJsonString() => jsonEncode(toFhirResource());
}
