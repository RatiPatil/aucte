import 'package:uuid/uuid.dart';

import '../../../core/services/shared_preferences_service.dart';
import '../../authentication/repositories/local_auth_repository.dart';
import '../models/encounter_model.dart';
import 'encounter_repository.dart';

class LocalEncounterRepository implements EncounterRepository {
  LocalEncounterRepository._();

  static final LocalEncounterRepository instance = LocalEncounterRepository._();

  final SharedPreferencesService _storage = SharedPreferencesService.instance;
  final Uuid _uuid = const Uuid();

  String get _encountersStorageKey => LocalAuthRepository.instance.clinicalStorageKey('aucte_local_encounters_list');

  Future<List<EncounterModel>> _loadEncounters() async {
    final list = _storage.getStringList(_encountersStorageKey);
    if (list == null || list.isEmpty) {
      return [];
    }

    final result = <EncounterModel>[];
    for (final item in list) {
      try {
        result.add(EncounterModel.fromJson(item));
      } catch (_) {}
    }
    return result;
  }

  Future<void> _saveEncounters(List<EncounterModel> encounters) async {
    final list = encounters.map((e) => e.toJson()).toList();
    await _storage.setStringList(_encountersStorageKey, list);
  }

  @override
  Future<List<EncounterModel>> getEncounters() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _loadEncounters();
  }

  @override
  Future<List<EncounterModel>> getEncountersByPatient(String patientId) async {
    final all = await _loadEncounters();
    return all.where((e) => e.patientId == patientId).toList();
  }

  @override
  Future<EncounterModel?> getEncounterById(String id) async {
    final all = await _loadEncounters();
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<EncounterModel> createEncounter(EncounterModel encounter) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final all = await _loadEncounters();

    final newEncounter = encounter.copyWith(
      id: encounter.id.isEmpty
          ? 'AUC-ENC-${_uuid.v4().substring(0, 6).toUpperCase()}'
          : encounter.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    all.insert(0, newEncounter);
    await _saveEncounters(all);
    return newEncounter;
  }

  @override
  Future<void> updateEncounter(EncounterModel encounter) async {
    final all = await _loadEncounters();
    final index = all.indexWhere((e) => e.id == encounter.id);
    if (index != -1) {
      all[index] = encounter.copyWith(updatedAt: DateTime.now());
      await _saveEncounters(all);
    }
  }

  @override
  Future<void> deleteEncounter(String id) async {
    final all = await _loadEncounters();
    all.removeWhere((e) => e.id == id);
    await _saveEncounters(all);
  }
}
