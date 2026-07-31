/// AUCTE — FHIR Bundle Repository.
library;

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mapping/models/mapping_result.dart';
import '../models/bundle_history_model.dart';
import '../models/fhir_bundle_model.dart';
import '../services/fhir_bundle_service.dart';
import '../services/fhir_service.dart';

class FhirBundleRepository {
  FhirBundleRepository({
    FhirBundleService? bundleService,
    SharedPreferences? sharedPreferences,
  })  : _bundleService = bundleService ?? FhirBundleService(),
        _prefs = sharedPreferences;

  final FhirBundleService _bundleService;
  final SharedPreferences? _prefs;

  static const String _bundleHistoryKey = 'fhir_bundle_history_list';
  static const int _maxHistoryItems = 20;

  /// Generates a valid FHIR R4 Bundle from mapping results.
  FhirBundleModel generateBundle({
    required MappingResult mapping,
    required String practitionerName,
  }) {
    return _bundleService.createBundle(
      mapping: mapping,
      practitionerName: practitionerName,
    );
  }

  /// Validates structural & reference integrity of a FHIR Bundle.
  FhirValidationResult validateBundle(FhirBundleModel bundle) {
    return _bundleService.validateBundle(bundle);
  }

  /// Prepares formatted JSON string for export (Pretty or Raw).
  String exportBundle(FhirBundleModel bundle, {bool pretty = true}) {
    if (pretty) {
      return bundle.toPrettyJson();
    }
    return jsonEncode(bundle.toJson());
  }

  /// Copies bundle JSON to system clipboard.
  Future<void> copyBundle(FhirBundleModel bundle, {bool pretty = true}) async {
    final jsonStr = exportBundle(bundle, pretty: pretty);
    await Clipboard.setData(ClipboardData(text: jsonStr));
  }

  /// Persists bundle history record locally in SharedPreferences.
  Future<void> saveBundleHistory(
    FhirBundleModel bundle, {
    required String namasteCode,
    required String generatedBy,
    required String validationStatus,
  }) async {
    if (_prefs == null) return;

    final historyItem = BundleHistoryModel(
      bundleId: bundle.id,
      namasteCode: namasteCode,
      generatedTime: bundle.timestamp,
      generatedBy: generatedBy,
      validationStatus: validationStatus,
      resourceCount: bundle.total,
      jsonContent: bundle.toPrettyJson(),
    );

    final currentHistory = getBundleHistory();
    // Remove duplicate if exists
    currentHistory.removeWhere((item) => item.bundleId == bundle.id);
    currentHistory.insert(0, historyItem);

    if (currentHistory.length > _maxHistoryItems) {
      currentHistory.removeLast();
    }

    final jsonList = currentHistory.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_bundleHistoryKey, jsonList);
  }

  /// Retrieves list of saved bundle history items.
  List<BundleHistoryModel> getBundleHistory() {
    if (_prefs == null) return [];
    final jsonList = _prefs.getStringList(_bundleHistoryKey) ?? [];

    return jsonList
        .map((jsonStr) {
          try {
            final Map<String, dynamic> map = jsonDecode(jsonStr);
            return BundleHistoryModel.fromJson(map);
          } catch (_) {
            return null;
          }
        })
        .whereType<BundleHistoryModel>()
        .toList();
  }

  /// Clears stored bundle history.
  Future<void> clearBundleHistory() async {
    if (_prefs == null) return;
    await _prefs.remove(_bundleHistoryKey);
  }
}
