import '../models/fhir_bundle_model.dart';

abstract class FhirRecordRepository {
  Future<List<FhirBundleModel>> getBundles();
  Future<FhirBundleModel?> getBundleById(String id);
  Future<List<FhirBundleModel>> getBundlesByPatient(String patientId);
  Future<FhirBundleModel?> getBundleByEncounter(String encounterId);
  Future<void> saveBundle(FhirBundleModel bundle);
  Future<void> deleteBundle(String id);
  Future<List<FhirBundleModel>> searchBundles(String query);
}
