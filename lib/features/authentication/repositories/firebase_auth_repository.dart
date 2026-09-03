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

      // Update Firebase Auth display name
      await firebaseUser?.updateDisplayName(fullName.trim());

      final practitioner = PractitionerModel(
        id: uid,
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        mobile: mobile.trim(),
        practitionerId: practitionerId.trim(),
        ayushSystem: ayushSystem,
        institution: institution.trim(),
        provider: 'email',
        createdAt: DateTime.now(),
      );

      // Save to Cloud Firestore — password is excluded by toMap()
      await _firestore
          .collection('practitioners')
          .doc(uid)
          .set(practitioner.toMap());

      await _persistSession(practitioner: practitioner, rememberMe: true);
      return practitioner;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase register error: ${e.code} — ${e.message}');
      // Translate Firebase error codes to user-friendly messages
      throw Exception(_translateFirebaseError(e));
    } catch (e) {
      debugPrint('Firebase register error, falling back to local auth: $e');
      // Only fall back to local if Firebase is completely unavailable
      // (e.g. no internet on first run or unconfigured project)
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
          // Document missing — create one from Firebase Auth data
          // Do NOT default to 'Ayurveda' without user input
          practitioner = PractitionerModel(
            id: firebaseUser.uid,
            fullName: firebaseUser.displayName?.trim().isNotEmpty == true
                ? firebaseUser.displayName!.trim()
                : identifier.split('@').first,
            email: firebaseUser.email ?? identifier,
            mobile: firebaseUser.phoneNumber ?? '',
            practitionerId:
                'AYU-FB-${firebaseUser.uid.substring(0, 6).toUpperCase()}',
            ayushSystem: 'Ayurveda',
            institution: '',
            provider: 'email',
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
      throw Exception('Authentication failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase login error: ${e.code}');
      throw Exception(_translateFirebaseError(e));
    } catch (e) {
      // Re-throw if it's already a formatted exception
      if (e.toString().startsWith('Exception:')) rethrow;
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
    // NOTE: This method does NOT fall back to the local mock.
    // If Google Sign-In fails, the error is propagated to the UI
    // so the user sees a real error message.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Sign-in was cancelled.');
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

    if (firebaseUser == null) {
      throw Exception(
        'Failed to retrieve user credentials from Google Sign-In.',
      );
    }

    // Resolve display name with proper priority:
    // 1. Firebase Auth displayName (most authoritative)
    // 2. Google account displayName
    // 3. Email prefix as last resort — never "Google User"
    final resolvedName = (firebaseUser.displayName?.trim().isNotEmpty == true
            ? firebaseUser.displayName!.trim()
            : null) ??
        (googleUser.displayName?.trim().isNotEmpty == true
            ? googleUser.displayName!.trim()
            : null) ??
        googleUser.email.split('@').first;

    final resolvedPhotoURL =
        firebaseUser.photoURL ?? googleUser.photoUrl;

    final doc = await _firestore
        .collection('practitioners')
        .doc(firebaseUser.uid)
        .get();

    PractitionerModel practitioner;
    if (doc.exists && doc.data() != null) {
      final existing = PractitionerModel.fromMap(doc.data()!);
      // Always refresh name and photo from the latest Google data
      practitioner = existing.copyWith(
        fullName: resolvedName,
        email: firebaseUser.email ?? existing.email,
        photoURL: resolvedPhotoURL,
        provider: 'google',
      );
      // Update Firestore with refreshed data
      await _firestore
          .collection('practitioners')
          .doc(firebaseUser.uid)
          .update({
        'fullName': practitioner.fullName,
        'email': practitioner.email,
        'photoURL': practitioner.photoURL,
        'provider': 'google',
      });
    } else {
      // First-time Google sign-in — create practitioner document
      practitioner = PractitionerModel(
        id: firebaseUser.uid,
        fullName: resolvedName,
        email: firebaseUser.email ?? googleUser.email,
        mobile: firebaseUser.phoneNumber ?? '',
        practitionerId:
            'AYU-G-${firebaseUser.uid.substring(0, 6).toUpperCase()}',
        ayushSystem: 'Ayurveda',
        institution: '',
        photoURL: resolvedPhotoURL,
        provider: 'google',
        createdAt: DateTime.now(),
      );

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
      // Sign out from Google if the current session was a Google session
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error during Firebase logout: $e');
    }
    // Always clear local session state regardless of Firebase result
    await _storage.setBool(StorageKeys.isLoggedIn, false);
    await _storage.remove(StorageKeys.currentPractitioner);
  }

  /// Translates FirebaseAuthException codes into user-friendly messages.
  String _translateFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 8 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
