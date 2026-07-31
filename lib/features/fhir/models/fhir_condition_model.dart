/// AUCTE — FHIR Condition Model.
library;

import 'fhir_resource.dart';

class FhirConditionModel extends FhirResource {
  const FhirConditionModel({
    required this.id,
    required this.subjectId,
    required this.encounterId,
    required this.recorderId,
    required this.recordedDate,
    required this.clinicalStatus,
    required this.verificationStatus,
    required this.namasteCode,
    required this.namasteDisplay,
    required this.tm2Code,
    required this.tm2Display,
    required this.icd11Code,
    required this.icd11Display,
  });

  final String id;
  final String subjectId;
  final String encounterId;
  final String recorderId;
  final DateTime recordedDate;
  final String clinicalStatus;
  final String verificationStatus;
  final String namasteCode;
  final String namasteDisplay;
  final String tm2Code;
  final String tm2Display;
  final String icd11Code;
  final String icd11Display;

  @override
  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Condition',
      'id': id,
      'clinicalStatus': {
        'coding': [
          {
            'system': 'http://terminology.hl7.org/CodeSystem/condition-clinical',
            'code': clinicalStatus,
          }
        ]
      },
      'verificationStatus': {
        'coding': [
          {
            'system': 'http://terminology.hl7.org/CodeSystem/condition-ver-status',
            'code': verificationStatus,
          }
        ]
      },
      'code': {
        'coding': [
          {
            'system': 'http://aucte.gov.in/namaste',
            'code': namasteCode,
            'display': namasteDisplay,
          },
          {
            'system': 'http://who.int/tm2',
            'code': tm2Code,
            'display': tm2Display,
          },
          {
            'system': 'http://hl7.org/fhir/sid/icd-11',
            'code': icd11Code,
            'display': icd11Display,
          },
        ],
        'text': namasteDisplay,
      },
      'subject': {
        'reference': 'Patient/$subjectId',
      },
      'encounter': {
        'reference': 'Encounter/$encounterId',
      },
      'recordedDate': FhirResource.formatFhirDateTime(recordedDate),
      'recorder': {
        'reference': 'Practitioner/$recorderId',
      },
    };
  }
}
