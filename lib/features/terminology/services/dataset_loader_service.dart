/// AUCTE — Dataset Loader Service.
///
/// Handles reading local JSON datasets from assets/datasets/, validating
/// duplicate codes, broken references, and missing mappings, and executing
/// batched imports into Cloud Firestore with local SharedPreferences initialization tracking.
library;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mapping/models/concept_map_model.dart';
import '../../mapping/models/icd11_code_model.dart';
import '../../mapping/models/tm2_code_model.dart';
import '../models/namaste_code_model.dart';

class DatasetValidationReport {
  const DatasetValidationReport({
    required this.isValid,
    required this.totalRecords,
    required this.errors,
    required this.warnings,
  });

  final bool isValid;
  final int totalRecords;
  final List<String> errors;
  final List<String> warnings;

  @override
  String toString() =>
      'ValidationReport(isValid: $isValid, records: $totalRecords, errors: ${errors.length}, warnings: ${warnings.length})';
}

class DatasetLoaderService {
  DatasetLoaderService({
    FirebaseFirestore? firestore,
    SharedPreferences? sharedPreferences,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = sharedPreferences;

  final FirebaseFirestore _firestore;
  final SharedPreferences? _prefs;

  static const String _initFlagKey = 'aucte_datasets_imported_v1';

  /// Assets paths for offline JSON datasets
  static const String _namasteAsset = 'assets/datasets/namaste_codes.json';
  static const String _tm2Asset = 'assets/datasets/tm2_codes.json';
  static const String _icd11Asset = 'assets/datasets/icd11_codes.json';
  static const String _conceptMapsAsset = 'assets/datasets/concept_maps.json';
  static const String _versionsAsset = 'assets/datasets/terminology_versions.json';

  /// Checks whether datasets have already been imported into Firestore.
  bool get isImported => _prefs?.getBool(_initFlagKey) ?? false;

  /// Loads and validates local JSON datasets for data integrity before import.
  Future<DatasetValidationReport> validateDatasets() async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      // 1. Load JSON strings
      final namasteStr = await rootBundle.loadString(_namasteAsset);
      final tm2Str = await rootBundle.loadString(_tm2Asset);
      final icd11Str = await rootBundle.loadString(_icd11Asset);
      final conceptMapsStr = await rootBundle.loadString(_conceptMapsAsset);

      final List<dynamic> namasteRaw = jsonDecode(namasteStr);
      final List<dynamic> tm2Raw = jsonDecode(tm2Str);
      final List<dynamic> icd11Raw = jsonDecode(icd11Str);
      final List<dynamic> conceptMapsRaw = jsonDecode(conceptMapsStr);

      final namasteCodes = <String>{};
      final tm2Codes = <String>{};
      final icd11Codes = <String>{};

      // 2. Validate NAMASTE codes
      for (final item in namasteRaw) {
        final code = item['code'] as String?;
        final name = item['name'] as String?;
        if (code == null || code.isEmpty) {
          errors.add('Found NAMASTE entry with empty code.');
          continue;
        }
        if (name == null || name.isEmpty) {
          errors.add('NAMASTE code $code has empty name.');
        }
        if (namasteCodes.contains(code)) {
          errors.add('Duplicate NAMASTE code found: $code');
        }
        namasteCodes.add(code);
      }

      // 3. Validate TM2 codes
      for (final item in tm2Raw) {
        final code = item['code'] as String?;
        if (code == null || code.isEmpty) {
          errors.add('Found TM2 entry with empty code.');
          continue;
        }
        if (tm2Codes.contains(code)) {
          errors.add('Duplicate TM2 code found: $code');
        }
        tm2Codes.add(code);
      }

      // 4. Validate ICD-11 codes
      for (final item in icd11Raw) {
        final code = item['code'] as String?;
        if (code == null || code.isEmpty) {
          errors.add('Found ICD-11 entry with empty code.');
          continue;
        }
        if (icd11Codes.contains(code)) {
          errors.add('Duplicate ICD-11 code found: $code');
        }
        icd11Codes.add(code);
      }

      // 5. Validate Concept Maps & reference integrity
      final mappedNamaste = <String>{};
      for (final item in conceptMapsRaw) {
        final nCode = item['namasteCode'] as String?;
        final tCode = item['tm2Code'] as String?;
        final iCode = item['icd11Code'] as String?;

        if (nCode == null || nCode.isEmpty) {
          errors.add('ConceptMap entry missing namasteCode.');
          continue;
        }

        if (!namasteCodes.contains(nCode)) {
          errors.add('Broken ConceptMap reference: namasteCode $nCode does not exist in namaste_codes.json.');
        }

        if (tCode != null && tCode.isNotEmpty && !tm2Codes.contains(tCode)) {
          errors.add('Broken ConceptMap reference: tm2Code $tCode does not exist in tm2_codes.json.');
        }

        if (iCode != null && iCode.isNotEmpty && !icd11Codes.contains(iCode)) {
          errors.add('Broken ConceptMap reference: icd11Code $iCode does not exist in icd11_codes.json.');
        }

        if (mappedNamaste.contains(nCode)) {
          warnings.add('NAMASTE code $nCode has multiple ConceptMap mappings.');
        }
        mappedNamaste.add(nCode);
      }

      // 6. Check unmapped NAMASTE codes
      final unmapped = namasteCodes.difference(mappedNamaste);
      if (unmapped.isNotEmpty) {
        warnings.add('The following NAMASTE codes lack concept mappings: ${unmapped.join(', ')}');
      }

      final total = namasteRaw.length + tm2Raw.length + icd11Raw.length + conceptMapsRaw.length;

      return DatasetValidationReport(
        isValid: errors.isEmpty,
        totalRecords: total,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Failed to load JSON asset files: $e');
      return DatasetValidationReport(
        isValid: false,
        totalRecords: 0,
        errors: errors,
        warnings: warnings,
      );
    }
  }

  /// Automatically imports all offline JSON datasets into Firestore.
  Future<bool> bootstrapImport({
    void Function(int imported, int total, String status)? onProgress,
    bool forceReimport = false,
  }) async {
    if (isImported && !forceReimport) {
      debugPrint('[AUCTE DatasetLoader] Datasets already imported. Skipping.');
      return true;
    }

    onProgress?.call(0, 100, 'Validating local JSON datasets...');
    final validation = await validateDatasets();
    if (!validation.isValid) {
      debugPrint('[AUCTE DatasetLoader] Validation failed: ${validation.errors}');
      return false;
    }

    try {
      // 1. Read JSON assets
      onProgress?.call(10, 100, 'Reading local JSON datasets...');
      final namasteStr = await rootBundle.loadString(_namasteAsset);
      final tm2Str = await rootBundle.loadString(_tm2Asset);
      final icd11Str = await rootBundle.loadString(_icd11Asset);
      final conceptMapsStr = await rootBundle.loadString(_conceptMapsAsset);
      final versionsStr = await rootBundle.loadString(_versionsAsset);

      final List<dynamic> namasteRaw = jsonDecode(namasteStr);
      final List<dynamic> tm2Raw = jsonDecode(tm2Str);
      final List<dynamic> icd11Raw = jsonDecode(icd11Str);
      final List<dynamic> conceptMapsRaw = jsonDecode(conceptMapsStr);
      final Map<String, dynamic> versionsRaw = jsonDecode(versionsStr);

      final totalRecords = validation.totalRecords + 1;
      var processed = 0;

      // 2. Helper batch writer (max 500 operations per batch)
      Future<void> writeBatch(
        String collectionName,
        List<Map<String, dynamic>> docs,
        String keyField,
      ) async {
        final collection = _firestore.collection(collectionName);
        var batch = _firestore.batch();
        var countInBatch = 0;

        for (final docData in docs) {
          final docId = docData[keyField] as String;
          final docRef = collection.doc(docId);
          batch.set(docRef, docData, SetOptions(merge: true));
          countInBatch++;
          processed++;

          if (countInBatch >= 450) {
            await batch.commit();
            batch = _firestore.batch();
            countInBatch = 0;
            onProgress?.call(
              (processed / totalRecords * 100).round(),
              totalRecords,
              'Imported $processed of $totalRecords records...',
            );
          }
        }

        if (countInBatch > 0) {
          await batch.commit();
        }
      }

      // 3. Import NAMASTE codes
      onProgress?.call(20, totalRecords, 'Importing NAMASTE codes...');
      final namasteDocs = namasteRaw.map((item) {
        final model = NamasteCodeModel.fromJson(item as Map<String, dynamic>);
        final json = model.toJson();
        return {'code': model.code, ...json};
      }).toList();
      await writeBatch('namaste_codes', namasteDocs, 'code');

      // 4. Import TM2 codes
      onProgress?.call(50, totalRecords, 'Importing WHO TM2 codes...');
      final tm2Docs = tm2Raw.map((item) {
        final model = TM2CodeModel.fromJson(item as Map<String, dynamic>);
        return {'code': model.code, ...model.toJson()};
      }).toList();
      await writeBatch('tm2_codes', tm2Docs, 'code');

      // 5. Import ICD-11 codes
      onProgress?.call(70, totalRecords, 'Importing WHO ICD-11 codes...');
      final icd11Docs = icd11Raw.map((item) {
        final model = ICD11CodeModel.fromJson(item as Map<String, dynamic>);
        return {'code': model.code, ...model.toJson()};
      }).toList();
      await writeBatch('icd11_codes', icd11Docs, 'code');

      // 6. Import Concept Maps
      onProgress?.call(85, totalRecords, 'Importing Concept Maps...');
      final mapDocs = conceptMapsRaw.map((item) {
        final model = ConceptMapModel.fromJson(item as Map<String, dynamic>);
        final docId = 'MAP-${model.namasteCode}';
        return {'id': docId, ...model.toJson()};
      }).toList();
      await writeBatch('concept_maps', mapDocs, 'id');

      // 7. Import Version Metadata
      onProgress?.call(95, totalRecords, 'Saving Version Metadata...');
      await _firestore
          .collection('terminology_versions')
          .doc(versionsRaw['version'] as String? ?? 'v1')
          .set(versionsRaw, SetOptions(merge: true));

      // 8. Save initialization flag in SharedPreferences
      await _prefs?.setBool(_initFlagKey, true);
      onProgress?.call(100, totalRecords, 'Offline terminology import completed successfully!');

      debugPrint('[AUCTE DatasetLoader] Successfully imported $totalRecords records into Firestore.');
      return true;
    } catch (e) {
      debugPrint('[AUCTE DatasetLoader] Import failed (running demo fallback): $e');
      return false;
    }
  }
}
