import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/shared_preferences_service.dart';
import '../models/practitioner_model.dart';
import 'auth_repository.dart';
import 'local_auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository._();

  static final FirebaseAuthRepository instance = FirebaseAuthRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferencesService _storage = SharedPreferencesService.instance;
  final LocalAuthRepository _localAuth = LocalAuthRepository.instance;
  final Uuid _uuid = const Uuid();

  @override
  bool get isLoggedIn => _storage.getBool(StorageKeys.isLoggedIn) ?? false;

  @override
  bool get rememberLogin =>
      _storage.getBool(StorageKeys.rememberLogin) ?? false;

  @override
  String? getRememberedIdentifier() {
    if (!rememberLogin) return null;
    return _storage.getString(StorageKeys.rememberedIdentifier);
  }

  @override
  PractitionerModel? getCurrentPractitioner() {
    final json = _storage.getString(StorageKeys.currentPractitioner);
    if (json == null || json.isEmpty) return null;
    try {
      return PractitionerModel.fromJson(json);
    } catch (_) {
      return null;
    }
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
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      final uid = firebaseUser?.uid ?? _uuid.v4();

      final practitioner = PractitionerModel(
        id: uid,
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        mobile: mobile.trim(),
        practitionerId: practitionerId.trim(),
        ayushSystem: ayushSystem,
        institution: institution.trim(),
        password: '', // Do not store plaintext password
        createdAt: DateTime.now(),
      );

      // Save to Cloud Firestore
      await _firestore
          .collection('practitioners')
          .doc(uid)
          .set(practitioner.toMap());

      await _persistSession(practitioner: practitioner, rememberMe: true);
      return practitioner;
    } catch (e) {
      debugPrint('Firebase register error, falling back to local auth: $e');
      // If Firebase auth is not yet configured, fall back to local auth
      return await _localAuth.register(
        fullName: fullName,
        email: email,
        mobile: mobile,
        practitionerId: practitionerId,
        ayushSystem: ayushSystem,
        institution: institution,
        password: password,
      );
    }
  }

  @override
  Future<PractitionerModel> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: identifier.trim(),
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final doc = await _firestore
            .collection('practitioners')
            .doc(firebaseUser.uid)
            .get();

        PractitionerModel practitioner;
        if (doc.exists && doc.data() != null) {
          practitioner = PractitionerModel.fromMap(doc.data()!);
        } else {
          practitioner = PractitionerModel(
            id: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? 'Practitioner',
            email: firebaseUser.email ?? identifier,
            mobile: firebaseUser.phoneNumber ?? '',
            practitionerId: 'AYU-FB-${firebaseUser.uid.substring(0, 6)}',
            ayushSystem: 'Ayurveda',
            institution: 'Registered Medical Center',
            password: '',
            createdAt: DateTime.now(),
          );

          await _firestore
              .collection('practitioners')
              .doc(firebaseUser.uid)
              .set(practitioner.toMap());
        }

        await _persistSession(
          practitioner: practitioner,
          rememberMe: rememberMe,
          identifier: identifier,
        );
        return practitioner;
      }
      throw Exception('Failed to sign in with Firebase');
    } catch (e) {
      debugPrint('Firebase login error, trying local auth fallback: $e');
      return await _localAuth.login(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
      );
    }
  }

  @override
  Future<PractitionerModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final doc = await _firestore
            .collection('practitioners')
            .doc(firebaseUser.uid)
            .get();

        PractitionerModel practitioner;
        if (doc.exists && doc.data() != null) {
          practitioner = PractitionerModel.fromMap(doc.data()!);
        } else {
          practitioner = PractitionerModel(
            id: firebaseUser.uid,
            fullName: googleUser.displayName ?? 'Dr. Google User',
            email: googleUser.email,
            mobile: firebaseUser.phoneNumber ?? '',
            practitionerId:
                'AYU-G-${firebaseUser.uid.substring(0, 6).toUpperCase()}',
            ayushSystem: 'Ayurveda',
            institution: 'AYUSH Clinical Network',
            password: '',
            createdAt: DateTime.now(),
          );

          // Add user data to Firestore
          await _firestore
              .collection('practitioners')
              .doc(firebaseUser.uid)
              .set(practitioner.toMap());
        }

        await _persistSession(
          practitioner: practitioner,
          rememberMe: true,
          identifier: googleUser.email,
        );
        return practitioner;
      }

      throw Exception(
        'Failed to retrieve user credentials from Google Sign-In',
      );
    } catch (e) {
      debugPrint('Google Sign-In error / fallback: $e');
      // If native Google Auth fails or is unconfigured, fallback to mock Google Auth for preview
      return await _localAuth.signInWithGoogle();
    }
  }

  Future<void> _persistSession({
    required PractitionerModel practitioner,
    required bool rememberMe,
    String? identifier,
  }) async {
    await _storage.setBool(StorageKeys.isLoggedIn, true);
    await _storage.setString(
      StorageKeys.currentPractitioner,
      practitioner.toJson(),
    );
    await _storage.setBool(StorageKeys.rememberLogin, rememberMe);

    if (rememberMe && (identifier != null || practitioner.email.isNotEmpty)) {
      await _storage.setString(
        StorageKeys.rememberedIdentifier,
        identifier ?? practitioner.email,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error during Firebase logout: $e');
    }
    await _localAuth.logout();
  }
}
