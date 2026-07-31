/// AUCTE — Mapping Result Object.
library;

import '../../terminology/models/namaste_code_model.dart';
import 'concept_map_model.dart';
import 'icd11_code_model.dart';
import 'tm2_code_model.dart';

class MappingResult {
  const MappingResult({
    required this.namaste,
    required this.conceptMap,
    this.tm2,
    this.icd11,
  });

  final NamasteCodeModel namaste;
  final ConceptMapModel conceptMap;
  final TM2CodeModel? tm2;
  final ICD11CodeModel? icd11;
}
