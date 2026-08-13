import '../models/clinical_term_model.dart';

abstract class TerminologyRepository {
  Future<List<ClinicalTermModel>> getAllTerms();

  Future<List<ClinicalTermModel>> search(String query);

  Future<List<ClinicalTermModel>> filterBySystem(String system);

  Future<ClinicalTermModel?> getById(String id);
}
