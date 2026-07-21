/// AUCTE — Application entry point.
///
/// Initializes Firebase (with graceful fallback), binds Flutter,
/// and wraps the app in a Riverpod [ProviderScope].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — falls back to demo mode on failure
  await FirebaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: AucteApp(),
    ),
  );
}
