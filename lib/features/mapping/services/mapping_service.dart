/// AUCTE — Mapping Service.
library;

import '../../terminology/repositories/terminology_repository.dart';
import '../models/mapping_result.dart';
import '../repositories/mapping_repository.dart';

class MappingService {
  MappingService({
    required IMappingRepository mappingRepository,
    required ITerminologyRepository terminologyRepository,
  })  : _mappingRepository = mappingRepository,
        _terminologyRepository = terminologyRepository;

  final IMappingRepository _mappingRepository;
  final ITerminologyRepository _terminologyRepository;

  /// Retrieves the complete mapping result for a given NAMASTE code.
  Future<MappingResult?> getMappingResult(String namasteCode) async {
    // 1. Fetch NAMASTE Terminology
    final namaste = await _terminologyRepository.getTerminologyByCode(namasteCode);
    if (namaste == null) return null;

    // 2. Fetch Concept Map
    final conceptMap = await _mappingRepository.getMappingByNamaste(namasteCode);
    if (conceptMap == null) return null; // No mapping exists

    // 3. Fetch TM2 and ICD-11 concurrently
    final futures = await Future.wait([
      _mappingRepository.getTM2ByCode(conceptMap.tm2Code),
      _mappingRepository.getICD11ByCode(conceptMap.icd11Code),
    ]);

    final tm2 = futures[0] as dynamic;
    final icd11 = futures[1] as dynamic;

    return MappingResult(
      namaste: namaste,
      conceptMap: conceptMap,
      tm2: tm2,
      icd11: icd11,
    );
  }
}
