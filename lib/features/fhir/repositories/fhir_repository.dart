/// AUCTE — FHIR Repository.
library;

import 'package:uuid/uuid.dart';

import '../models/fhir_condition_model.dart';
import '../models/fhir_encounter_model.dart';
import '../models/fhir_patient_model.dart';
import '../models/fhir_practitioner_model.dart';

class FhirRepository {
  final _uuid = const Uuid();

  String _generateId() => _uuid.v4();

  FhirPatientModel generatePatient() {
    return FhirPatientModel(
      id: _generateId(),
      name: 'Demo Patient',
      gender: 'unknown',
      birthDate: '1990-01-01',
    );
  }

  FhirPractitionerModel generatePractitioner(String practitionerName) {
    return FhirPractitionerModel(
      id: _generateId(),
      name: practitionerName,
    );
  }

  FhirEncounterModel generateEncounter(String subjectId) {
    return FhirEncounterModel(
      id: _generateId(),
      status: 'finished',
      classCode: 'AMB', // ambulatory
      subjectId: subjectId,
    );
  }

  FhirConditionModel generateCondition({
    required String subjectId,
    required String encounterId,
    required String recorderId,
    required String namasteCode,
    required String namasteDisplay,
    required String tm2Code,
    required String tm2Display,
    required String icd11Code,
    required String icd11Display,
  }) {
    return FhirConditionModel(
      id: _generateId(),
      subjectId: subjectId,
      encounterId: encounterId,
      recorderId: recorderId,
      recordedDate: DateTime.now(),
      clinicalStatus: 'active',
      verificationStatus: 'confirmed',
      namasteCode: namasteCode,
      namasteDisplay: namasteDisplay,
      tm2Code: tm2Code,
      tm2Display: tm2Display,
      icd11Code: icd11Code,
      icd11Display: icd11Display,
    );
  }
}
