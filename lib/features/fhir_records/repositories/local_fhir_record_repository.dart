import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../authentication/models/practitioner_model.dart';
import '../../authentication/repositories/local_auth_repository.dart';
import '../../consent/models/consent_model.dart';
import '../../encounters/repositories/local_encounter_repository.dart';
import '../../patients/repositories/local_patient_repository.dart';
import '../models/fhir_bundle_model.dart';
import '../services/fhir_builder_service.dart';
import 'fhir_record_repository.dart';

class LocalFhirRecordRepository implements FhirRecordRepository {
  LocalFhirRecordRepository._();

  static final LocalFhirRecordRepository instance =
      LocalFhirRecordRepository._();

  static const String _storageKey = 'aucte_fhir_bundles_v1';
  List<FhirBundleModel> _cachedBundles = [];
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey);

    if (rawList != null && rawList.isNotEmpty) {
      _cachedBundles = rawList
          .map((s) => FhirBundleModel.fromJson(s))
          .toList();
    } else {
      // Auto-synthesize bundles from existing demo encounters
      await _hydrateFromEncounters();
    }

    _isInitialized = true;
  }

  Future<void> _hydrateFromEncounters() async {
    final encRepo = LocalEncounterRepository.instance;
    final patientRepo = LocalPatientRepository.instance;
    final practitioner = LocalAuthRepository.instance.getCurrentPractitioner() ??
        PractitionerModel(
          id: 'DEMO-PRACT-001',
          fullName: 'Dr. AYUSH Specialist',
          email: 'doctor@ayush.gov.in',
          mobile: '9876543210',
          practitionerId: 'AYU-1001',
          ayushSystem: 'Ayurveda',
          institution: 'All India Institute of Ayurveda',
          password: '',
          createdAt: DateTime(2026, 1, 1),
        );

    final encounters = await encRepo.getEncounters();
    final patients = await patientRepo.getPatients();

    final patientMap = {for (var p in patients) p.id: p};
    final bundles = <FhirBundleModel>[];

    for (final enc in encounters) {
      final patient = patientMap[enc.patientId];
      if (patient != null) {
        final consent = enc.consentId != null
            ? ConsentModel(
                id: enc.consentId!,
                patientId: patient.id,
                encounterId: enc.id,
                practitionerId: practitioner.id,
                purpose:
                    'Clinical documentation, dual coding & FHIR record generation',
                status: 'granted',
                grantedAt: enc.encounterDate,
                version: '1.0',
                createdAt: enc.createdAt,
              )
            : null;

        final bundle = FHIRBuilderService.buildTypedBundle(
          patient: patient,
          practitioner: practitioner,
          encounter: enc,
          consent: consent,
        );
        bundles.add(bundle);
      }
    }

    _cachedBundles = bundles;
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = _cachedBundles.map((b) => jsonEncode(b.toFhirResource())).toList();
    await prefs.setStringList(_storageKey, stringList);
  }

  @override
  Future<List<FhirBundleModel>> getBundles() async {
    await _init();
    return List.unmodifiable(_cachedBundles);
  }

  @override
  Future<FhirBundleModel?> getBundleById(String id) async {
    await _init();
    try {
      return _cachedBundles.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FhirBundleModel>> getBundlesByPatient(String patientId) async {
    await _init();
    return _cachedBundles.where((b) => b.patient.id == patientId).toList();
  }

  @override
  Future<FhirBundleModel?> getBundleByEncounter(String encounterId) async {
    await _init();
    try {
      return _cachedBundles.firstWhere((b) => b.encounter.id == encounterId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveBundle(FhirBundleModel bundle) async {
    await _init();
    final index = _cachedBundles.indexWhere((b) => b.id == bundle.id);
    if (index >= 0) {
      _cachedBundles[index] = bundle;
    } else {
      _cachedBundles.insert(0, bundle);
    }
    await _saveToStorage();
  }

  @override
  Future<void> deleteBundle(String id) async {
    await _init();
    _cachedBundles.removeWhere((b) => b.id == id);
    await _saveToStorage();
  }

  @override
  Future<List<FhirBundleModel>> searchBundles(String query) async {
    await _init();
    if (query.trim().isEmpty) return List.unmodifiable(_cachedBundles);

    final q = query.trim().toLowerCase();
    return _cachedBundles.where((b) {
      final patMatch = b.patient.name.toLowerCase().contains(q) ||
          b.patient.id.toLowerCase().contains(q);
      final diagMatch = b.conditions.any((c) =>
          c.term.namasteTerm.toLowerCase().contains(q) ||
          c.term.namasteCode.toLowerCase().contains(q) ||
          c.term.tm2Code.toLowerCase().contains(q) ||
          c.term.biomedicineCode.toLowerCase().contains(q));
      final complaintMatch = b.encounter.reasonCodes
          .any((r) => r.toLowerCase().contains(q));
      final systemMatch =
          b.practitioner.ayushSystem.toLowerCase().contains(q);

      return patMatch || diagMatch || complaintMatch || systemMatch;
    }).toList();
  }
}
