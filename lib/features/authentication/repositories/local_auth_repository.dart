import 'package:uuid/uuid.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/shared_preferences_service.dart';
import '../models/practitioner_model.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository._();

  static final LocalAuthRepository instance = LocalAuthRepository._();

  final SharedPreferencesService _storage = SharedPreferencesService.instance;

  final Uuid _uuid = const Uuid();

  @override
  bool get isLoggedIn {
    return _storage.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  @override
  bool get rememberLogin {
    return _storage.getBool(StorageKeys.rememberLogin) ?? false;
  }

  @override
  String? getRememberedIdentifier() {
    if (!rememberLogin) {
      return null;
    }

    return _storage.getString(StorageKeys.rememberedIdentifier);
  }

  List<PractitionerModel> _getRegisteredUsers() {
    final values =
        _storage.getStringList(StorageKeys.registeredPractitioners) ?? [];

    final users = <PractitionerModel>[];

    for (final value in values) {
      try {
        users.add(PractitionerModel.fromJson(value));
      } catch (_) {
        // Ignore invalid demo records.
      }
    }

    return users;
  }

  Future<void> _saveUsers(List<PractitionerModel> users) async {
    await _storage.setStringList(
      StorageKeys.registeredPractitioners,
      users.map((user) => user.toJson()).toList(),
    );
  }

  @override
  Future<PractitionerModel> register({
    required String fullName,
    required String email,
    required String mobile,
    required String practitionerId,
    required String ayushSystem,
    required String institution,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final users = _getRegisteredUsers();

    final normalizedEmail = email.trim().toLowerCase();

    final normalizedPractitionerId = practitionerId.trim().toLowerCase();

    final emailExists = users.any(
      (user) => user.email.trim().toLowerCase() == normalizedEmail,
    );

    if (emailExists) {
      throw Exception('An account already exists with this email.');
    }

    final idExists = users.any(
      (user) =>
          user.practitionerId.trim().toLowerCase() == normalizedPractitionerId,
    );

    if (idExists) {
      throw Exception('This Practitioner ID is already registered.');
    }

    final practitioner = PractitionerModel(
      id: _uuid.v4(),
      fullName: fullName.trim(),
      email: normalizedEmail,
      mobile: mobile.trim(),
      practitionerId: practitionerId.trim(),
      ayushSystem: ayushSystem,
      institution: institution.trim(),
      password: password,
      createdAt: DateTime.now(),
    );

    users.add(practitioner);

    await _saveUsers(users);

    return practitioner;
  }

  @override
  Future<PractitionerModel> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final normalized = identifier.trim().toLowerCase();

    final users = _getRegisteredUsers();

    PractitionerModel? foundUser;

    for (final user in users) {
      final emailMatches = user.email.toLowerCase() == normalized;

      final practitionerIdMatches =
          user.practitionerId.toLowerCase() == normalized;

      if (emailMatches || practitionerIdMatches) {
        foundUser = user;
        break;
      }
    }

    if (foundUser == null) {
      throw Exception('No practitioner account was found.');
    }

    if (foundUser.password != password) {
      throw Exception('Incorrect password. Please try again.');
    }

    await _storage.setBool(StorageKeys.isLoggedIn, true);

    await _storage.setString(
      StorageKeys.currentPractitioner,
      foundUser.toJson(),
    );

    await _storage.setBool(StorageKeys.rememberLogin, rememberMe);

    if (rememberMe) {
      await _storage.setString(
        StorageKeys.rememberedIdentifier,
        identifier.trim(),
      );
    } else {
      await _storage.remove(StorageKeys.rememberedIdentifier);
    }

    return foundUser;
  }

  @override
  PractitionerModel? getCurrentPractitioner() {
    final json = _storage.getString(StorageKeys.currentPractitioner);

    if (json == null || json.isEmpty) {
      return null;
    }

    try {
      return PractitionerModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PractitionerModel> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final practitioner = PractitionerModel(
      id: _uuid.v4(),
      fullName: 'Dr. Google User',
      email: 'user@google.com',
      mobile: '+919876543210',
      practitionerId: 'AYU-G-1001',
      ayushSystem: 'Ayurveda',
      institution: 'All India Institute of Ayurveda',
      password: '',
      createdAt: DateTime.now(),
    );

    await _storage.setBool(StorageKeys.isLoggedIn, true);
    await _storage.setString(
      StorageKeys.currentPractitioner,
      practitioner.toJson(),
    );
    return practitioner;
  }

  @override
  Future<void> logout() async {
    await _storage.setBool(StorageKeys.isLoggedIn, false);

    await _storage.remove(StorageKeys.currentPractitioner);
  }
}
