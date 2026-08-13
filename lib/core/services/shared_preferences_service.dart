import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

class SharedPreferencesService implements LocalStorageService {
  SharedPreferencesService._();

  static final SharedPreferencesService instance = SharedPreferencesService._();

  SharedPreferences? _preferences;

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _prefs {
    final preferences = _preferences;

    if (preferences == null) {
      throw StateError(
        'SharedPreferencesService has not been initialized. '
        'Call initialize() before using it.',
      );
    }

    return preferences;
  }

  @override
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  @override
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  @override
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  @override
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  @override
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  @override
  Future<bool> clear() {
    return _prefs.clear();
  }
}
