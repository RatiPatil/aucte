import '../models/practitioner_model.dart';

abstract class AuthRepository {
  bool get isLoggedIn;

  bool get rememberLogin;

  String? getRememberedIdentifier();

  PractitionerModel? getCurrentPractitioner();

  Future<PractitionerModel> register({
    required String fullName,
    required String email,
    required String mobile,
    required String practitionerId,
    required String ayushSystem,
    required String institution,
    required String password,
  });

  Future<PractitionerModel> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  });

  Future<PractitionerModel> signInWithGoogle();

  Future<void> logout();
}
