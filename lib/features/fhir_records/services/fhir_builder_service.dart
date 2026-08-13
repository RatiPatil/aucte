import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../../authentication/models/practitioner_model.dart';
import '../../consent/models/consent_model.dart';
import '../../encounters/models/encounter_model.dart';
import '../../patients/models/patient_model.dart';
import '../models/fhir_condition_model.dart';

class FHIRBuilderService {
  static const Uuid _uuid = Uuid();

  static Map<String, dynamic> buildBundle({
    required PatientModel patient,
    required PractitionerModel practitioner,
    required EncounterModel encounter,
    ConsentModel? consent,
  }) {
    final bundleId = 'auc-bundle-${_uuid.v4().substring(0, 8)}';
    final timestamp = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> entries = [];

    // 1. Patient Resource
    final patientResource = {
      "fullUrl": "urn:uuid:${patient.id}",
      "resource": {
        "resourceType": "Patient",
        "id": patient.id,
        "identifier": [
          if (patient.abhaNumber != null && patient.abhaNumber!.isNotEmpty)
            {
              "system": "https://healthid.ndhm.gov.in",
              "value": patient.abhaNumber,
            },
          {
            "system": "https://aucte.ayush.gov.in/patient-id",
            "value": patient.id,
          },
        ],
        "name": [
          {"use": "official", "text": patient.fullName},
        ],
        "gender": patient.gender.toLowerCase() == 'male'
            ? 'male'
            : patient.gender.toLowerCase() == 'female'
            ? 'female'
            : 'other',
        "birthDate": patient.dateOfBirth.toIso8601String().split('T')[0],
        "telecom": [
          {"system": "phone", "value": patient.mobile, "use": "mobile"},
        ],
        "address": [
          {
            "line": [patient.address],
            "city": patient.city,
            "state": patient.state,
            "country": "India",
          },
        ],
      },
    };
    entries.add(patientResource);

    // 2. Practitioner Resource
    final practitionerResource = {
      "fullUrl": "urn:uuid:${practitioner.id}",
      "resource": {
        "resourceType": "Practitioner",
        "id": practitioner.id,
        "identifier": [
          {
            "system": "https://aucte.ayush.gov.in/practitioner-id",
            "value": practitioner.practitionerId,
          },
        ],
        "name": [
          {"text": practitioner.fullName},
        ],
        "qualification": [
          {
            "code": {"text": "AYUSH Specialist - ${practitioner.ayushSystem}"},
            "issuer": {"display": practitioner.institution},
          },
        ],
      },
    };
    entries.add(practitionerResource);

    // 3. Encounter Resource
    final encounterResource = {
      "fullUrl": "urn:uuid:${encounter.id}",
      "resource": {
        "resourceType": "Encounter",
        "id": encounter.id,
        "status": encounter.status,
        "class": {
          "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
          "code": "AMB",
          "display": "ambulatory",
        },
        "subject": {
          "reference": "Patient/${patient.id}",
          "display": patient.fullName,
        },
        "participant": [
          {
            "individual": {
              "reference": "Practitioner/${practitioner.id}",
              "display": practitioner.fullName,
            },
          },
        ],
        "period": {"start": encounter.encounterDate.toIso8601String()},
        "reasonCode": [
          {"text": encounter.chiefComplaint},
        ],
      },
    };
    entries.add(encounterResource);

    // 4. Condition Resources (Dual Coding)
    for (int i = 0; i < encounter.diagnoses.length; i++) {
      final term = encounter.diagnoses[i];
      final condModel = FhirConditionModel(
        resourceType: 'Condition',
        id: 'cond-${encounter.id}-$i',
        clinicalStatus: 'active',
        verificationStatus: 'confirmed',
        subjectId: patient.id,
        encounterId: encounter.id,
        recordedDate: encounter.encounterDate,
        term: term,
      );

      entries.add({
        "fullUrl": "urn:uuid:${condModel.id}",
        "resource": condModel.toFhirResource(),
      });
    }

    // 5. Consent Resource if present
    if (consent != null) {
      entries.add({
        "fullUrl": "urn:uuid:${consent.id}",
        "resource": {
          "resourceType": "Consent",
          "id": consent.id,
          "status": consent.status == 'granted' ? 'active' : 'inactive',
          "scope": {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/consentscope",
                "code": "patient-privacy",
                "display": "Patient Privacy",
              },
            ],
          },
          "category": [
            {
              "coding": [
                {
                  "system":
                      "http://terminology.hl7.org/CodeSystem/consentcategorycodes",
                  "code": "acd",
                  "display": "Advance Care Directive",
                },
              ],
            },
          ],
          "patient": {
            "reference": "Patient/${patient.id}",
            "display": patient.fullName,
          },
          "dateTime": consent.grantedAt.toIso8601String(),
          "policyRule": {"text": consent.purpose},
        },
      });
    }

    return {
      "resourceType": "Bundle",
      "id": bundleId,
      "type": "document",
      "timestamp": timestamp,
      "meta": {
        "profile": [
          "https://aucte.ayush.gov.in/fhir/StructureDefinition/aucte-clinical-document",
        ],
      },
      "entry": entries,
    };
  }

  static String buildFormattedJson({
    required PatientModel patient,
    required PractitionerModel practitioner,
    required EncounterModel encounter,
    ConsentModel? consent,
  }) {
    final bundle = buildBundle(
      patient: patient,
      practitioner: practitioner,
      encounter: encounter,
      consent: consent,
    );
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(bundle);
  }
}
