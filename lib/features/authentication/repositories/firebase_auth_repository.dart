import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/shared_preferences_service.dart';
import '../models/practitioner_model.dart';

class FirebaseAuthRepository {
  FirebaseAuthRepository._();

  static final instance = FirebaseAuthRepository._();
  static const demoPractitionerId = 'DEMO-PRACT-001';

  final _googleSignIn = GoogleSignIn();
  final _storage = SharedPreferencesService.instance;

  bool get googleConfigured => Firebase.apps.isNotEmpty;

  PractitionerModel? getCurrentPractitioner() {
    final json = _storage.getString(StorageKeys.currentPractitioner);
    if (json == null || _storage.getBool(StorageKeys.isLoggedIn) != true) {
      return null;
    }
    final PractitionerModel practitioner;
    try {
      practitioner = PractitionerModel.fromJson(json);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
    if (practitioner.id == demoPractitionerId) return practitioner;
    if (!googleConfigured || practitioner.provider != 'google') return null;
    final project = Firebase.app().options.projectId;
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid == practitioner.id &&
            project == _storage.getString(StorageKeys.authProject)
        ? practitioner
        : null;
  }

  Future<PractitionerModel> signInWithGoogle() async {
    if (!googleConfigured) {
      throw StateError(
        'Google sign-in needs the new Firebase Android configuration.',
      );
    }
    final google = await _googleSignIn.signIn();
    if (google == null) throw StateError('Google sign-in was cancelled.');
    final tokens = await google.authentication;
    final result = await FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
      ),
    );
    final user = result.user;
    if (user == null) throw StateError('Google sign-in returned no account.');
    final previous = getCurrentPractitioner();
    final name =
        [user.displayName, google.displayName, google.email.split('@').first]
            .whereType<String>()
            .map((name) => name.trim())
            .firstWhere((name) => name.isNotEmpty);
    final practitioner = PractitionerModel(
      id: user.uid,
      fullName: name,
      email: user.email ?? google.email,
      mobile: user.phoneNumber ?? '',
      practitionerId: user.uid,
      ayushSystem: 'Ayurveda',
      institution: '',
      photoURL: user.photoURL ?? google.photoUrl,
      provider: 'google',
      createdAt: previous?.id == user.uid
          ? previous!.createdAt
          : user.metadata.creationTime ?? DateTime.now(),
    );
    await _persist(practitioner, project: Firebase.app().options.projectId);
    return practitioner;
  }

  Future<void> startDemoSession() => _persist(
    PractitionerModel(
      id: demoPractitionerId,
      fullName: 'Dr. AUCTE Demo',
      email: 'demo@aucte.example',
      mobile: '',
      practitionerId: demoPractitionerId,
      ayushSystem: 'Ayurveda',
      institution: 'AUCTE Demonstration',
      provider: 'local',
      createdAt: DateTime.now(),
    ),
  );

  Future<void> _persist(
    PractitionerModel practitioner, {
    String? project,
  }) async {
    await _storage.setBool(StorageKeys.isLoggedIn, false);
    if (project == null) {
      await _storage.remove(StorageKeys.authProject);
    } else {
      await _storage.setString(StorageKeys.authProject, project);
    }
    await _storage.setString(
      StorageKeys.currentPractitioner,
      practitioner.toJson(),
    );
    await _storage.setBool(StorageKeys.isLoggedIn, true);
  }

  Future<void> logout() async {
    await _storage.setBool(StorageKeys.isLoggedIn, false);
    await _storage.remove(StorageKeys.currentPractitioner);
    await _storage.remove(StorageKeys.authProject);
    if (!googleConfigured) return;
    try {
      await FirebaseAuth.instance.signOut();
    } finally {
      await _googleSignIn.signOut();
    }
  }
}
