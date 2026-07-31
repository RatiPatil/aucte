/// AUCTE — Application entry point.
///
/// Initializes Firebase (with graceful fallback), binds Flutter,
/// and wraps the app in a Riverpod [ProviderScope].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/firebase_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/authentication/models/user_model.dart';
import 'features/authentication/models/user_role.dart';
import 'features/terminology/services/dataset_loader_service.dart';
import 'core/providers/shared_prefs_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — falls back to demo mode on failure
  await FirebaseConfig.initialize();
  
  // Initialize SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();
  
  // Seed database with dummy doctors for presentation (non-blocking)
  _seedDummyDoctors();
  
  // Import offline terminology datasets into Firestore (non-blocking)
  DatasetLoaderService(sharedPreferences: sharedPrefs)
      .bootstrapImport()
      .catchError((e) {
    debugPrint('Failed to import terminology datasets: $e');
    return false;
  });

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const AucteApp(),
    ),
  );
}

Future<void> _seedDummyDoctors() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final users = firestore.collection('users');
    
    final docs = [
      UserModel(
        uid: 'dummy-doc-1',
        email: 'dr.sharma@aucte.gov.in',
        displayName: 'Dr. Ayush Sharma',
        role: UserRole.doctor,
        approved: true,
        hospital: 'National Institute of Ayurveda',
        department: 'Panchakarma',
        designation: 'Senior Physician',
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: 'dummy-doc-2',
        email: 'dr.patil@aucte.gov.in',
        displayName: 'Dr. Rati Patil',
        role: UserRole.doctor,
        approved: true,
        hospital: 'All India Institute of Ayurveda',
        department: 'Shalya Tantra',
        designation: 'Chief Medical Officer',
        createdAt: DateTime.now(),
      ),
    ];
    
    for (final doc in docs) {
      final snapshot = await users.doc(doc.uid).get().timeout(const Duration(seconds: 3));
      if (!snapshot.exists) {
        await users.doc(doc.uid).set(doc.toJson()).timeout(const Duration(seconds: 3));
      }
    }
  } catch (e) {
    debugPrint('Failed to seed dummy doctors: $e');
  }
}
