import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../../authentication/models/practitioner_model.dart';
import '../../consent/models/consent_model.dart';
import '../../encounters/models/encounter_model.dart';
import '../../patients/models/patient_model.dart';
import '../../terminology/models/clinical_term_model.dart';
import '../models/fhir_bundle_model.dart';
import '../models/fhir_condition_model.dart';
import '../models/fhir_consent_model.dart';
import '../models/fhir_encounter_model.dart';
import '../models/fhir_patient_model.dart';
import '../models/fhir_practitioner_model.dart';

class FHIRBuilderService {
  static const Uuid _uuid = Uuid();

  /// Build a typed FhirBundleModel representing a full FHIR R4 document
  static FhirBundleModel buildTypedBundle({
    required PatientModel patient,
    required PractitionerModel practitioner,
    required EncounterModel encounter,
    ConsentModel? consent,
  }) {
    final bundleId = 'auc-bundle-${_uuid.v4().substring(0, 8)}';
    final timestamp = DateTime.now();

    // 1. Patient
    final fhirPatient = FhirPatientModel.fromPatientModel(patient);

    // 2. Practitioner
    final fhirPractitioner =
        FhirPractitionerModel.fromPractitionerModel(practitioner);

    // 3. Encounter
    final fhirEncounter = FhirEncounterModel.fromEncounterModel(
      encounter: encounter,
      patientName: patient.fullName,
      practitionerName: practitioner.fullName,
    );

    // 4. Dual-Coded Conditions
    final conditions = <FhirConditionModel>[];
    for (int i = 0; i < encounter.diagnoses.length; i++) {
      final term = encounter.diagnoses[i];
      conditions.add(
        FhirConditionModel(
          id: 'cond-${encounter.id.isNotEmpty ? encounter.id : 'temp'}-$i',
          clinicalStatus: 'active',
          verificationStatus: 'confirmed',
          subjectId: patient.id,
          encounterId: encounter.id,
          recordedDate: encounter.encounterDate,
          term: term,
        ),
      );
    }

    // 5. Consent
    final fhirConsent = consent != null
        ? FhirConsentModel.fromConsentModel(
            consent: consent,
            patientName: patient.fullName,
          )
        : null;

    return FhirBundleModel(
      id: bundleId,
      timestamp: timestamp,
      profileUrl:
          "https://aucte.ayush.gov.in/fhir/StructureDefinition/aucte-clinical-document",
      patient: fhirPatient,
      practitioner: fhirPractitioner,
      encounter: fhirEncounter,
      conditions: conditions,
      consent: fhirConsent,
    );
  }

  /// Backward-compatible map generator
  static Map<String, dynamic> buildBundle({
    required PatientModel patient,
    required PractitionerModel practitioner,
    required EncounterModel encounter,
    ConsentModel? consent,
  }) {
    final typed = buildTypedBundle(
      patient: patient,
      practitioner: practitioner,
      encounter: encounter,
      consent: consent,
    );
    return typed.toFhirResource();
  }

  /// Formatted indented JSON String from models
  static String buildFormattedJson({
    required PatientModel patient,
    required PractitionerModel practitioner,
    required EncounterModel encounter,
    ConsentModel? consent,
  }) {
    final typed = buildTypedBundle(
      patient: patient,
      practitioner: practitioner,
      encounter: encounter,
      consent: consent,
    );
    return typed.toFormattedJson();
  }

  /// Generate a standalone single FHIR Condition JSON snippet for any ClinicalTermModel
  static String buildConditionJson(ClinicalTermModel term) {
    final cond = FhirConditionModel.fromClinicalTerm(term);
    return cond.toJsonString();
  }

  /// Generate a standalone single FHIR Patient JSON snippet
  static String buildPatientJson(PatientModel patient) {
    final p = FhirPatientModel.fromPatientModel(patient);
    return p.toJsonString();
  }

  /// Format any generic FHIR resource map to formatted JSON string
  static String formatJson(Map<String, dynamic> resource) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(resource);
  }
}
