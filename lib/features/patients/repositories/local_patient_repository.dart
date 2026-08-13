import 'package:uuid/uuid.dart';

import '../../../core/services/shared_preferences_service.dart';
import '../models/patient_model.dart';
import 'patient_repository.dart';

class LocalPatientRepository implements PatientRepository {
  LocalPatientRepository._();

  static final LocalPatientRepository instance = LocalPatientRepository._();

  final SharedPreferencesService _storage = SharedPreferencesService.instance;
  final Uuid _uuid = const Uuid();

  static const String _patientsStorageKey = 'aucte_local_patients_list';

  final List<PatientModel> _seedPatients = [
    PatientModel(
      id: 'AUC-PAT-1001',
      fullName: 'Rahul Patil',
      gender: 'Male',
      dateOfBirth: DateTime(1992, 4, 15),
      mobile: '9876543210',
      abhaNumber: '91-8842-1092-3841',
      address: '14, Green Park Colony, MG Road',
      city: 'Pune',
      state: 'Maharashtra',
      bloodGroup: 'O+',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PatientModel(
      id: 'AUC-PAT-1002',
      fullName: 'Anita Sharma',
      gender: 'Female',
      dateOfBirth: DateTime(1984, 8, 22),
      mobile: '9876501234',
      abhaNumber: '91-4412-9081-7721',
      address: 'B-402, Sunshine Heights, Civil Lines',
      city: 'Jaipur',
      state: 'Rajasthan',
      bloodGroup: 'B+',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PatientModel(
      id: 'AUC-PAT-1003',
      fullName: 'Priya Verma',
      gender: 'Female',
      dateOfBirth: DateTime(1997, 11, 3),
      mobile: '9822001122',
      abhaNumber: null,
      address: '77, Annasalai Street',
      city: 'Chennai',
      state: 'Tamil Nadu',
      bloodGroup: 'A+',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
  ];

  Future<List<PatientModel>> _loadPatients() async {
    final list = _storage.getStringList(_patientsStorageKey);
    if (list == null || list.isEmpty) {
      await _savePatients(_seedPatients);
      return List.from(_seedPatients);
    }

    final result = <PatientModel>[];
    for (final item in list) {
      try {
        result.add(PatientModel.fromJson(item));
      } catch (_) {}
    }
    return result;
  }

  Future<void> _savePatients(List<PatientModel> patients) async {
    final list = patients.map((p) => p.toJson()).toList();
    await _storage.setStringList(_patientsStorageKey, list);
  }

  @override
  Future<List<PatientModel>> getPatients() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _loadPatients();
  }

  @override
  Future<List<PatientModel>> searchPatients(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final patients = await _loadPatients();
    if (query.trim().isEmpty) return patients;

    final q = query.trim().toLowerCase();
    return patients.where((p) {
      final nameMatches = p.fullName.toLowerCase().contains(q);
      final idMatches = p.id.toLowerCase().contains(q);
      final phoneMatches = p.mobile.contains(q);
      final abhaMatches = p.abhaNumber?.toLowerCase().contains(q) ?? false;
      return nameMatches || idMatches || phoneMatches || abhaMatches;
    }).toList();
  }

  @override
  Future<PatientModel?> getPatientById(String id) async {
    final patients = await _loadPatients();
    for (final p in patients) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<PatientModel> addPatient(PatientModel patient) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final patients = await _loadPatients();

    final newPatient = patient.copyWith(
      id: patient.id.isEmpty
          ? 'AUC-PAT-${_uuid.v4().substring(0, 6).toUpperCase()}'
          : patient.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    patients.insert(0, newPatient);
    await _savePatients(patients);
    return newPatient;
  }

  @override
  Future<void> updatePatient(PatientModel patient) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final patients = await _loadPatients();
    final index = patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      patients[index] = patient.copyWith(updatedAt: DateTime.now());
      await _savePatients(patients);
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    final patients = await _loadPatients();
    patients.removeWhere((p) => p.id == id);
    await _savePatients(patients);
  }
}
