import '../models/patient_model.dart';

abstract class PatientRepository {
  Future<List<PatientModel>> getPatients();

  Future<List<PatientModel>> searchPatients(String query);

  Future<PatientModel?> getPatientById(String id);

  Future<PatientModel> addPatient(PatientModel patient);

  Future<void> updatePatient(PatientModel patient);

  Future<void> deletePatient(String id);
}
