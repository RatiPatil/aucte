import '../models/encounter_model.dart';

abstract class EncounterRepository {
  Future<List<EncounterModel>> getEncounters();

  Future<List<EncounterModel>> getEncountersByPatient(String patientId);

  Future<EncounterModel?> getEncounterById(String id);

  Future<EncounterModel> createEncounter(EncounterModel encounter);

  Future<void> updateEncounter(EncounterModel encounter);

  Future<void> deleteEncounter(String id);
}
