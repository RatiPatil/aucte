/// Firebase initialization helper for AUCTE.
///
/// Wraps Firebase.initializeApp with error handling and graceful
/// fallback to demo mode when firebase_options.dart is not configured.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options_stub.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initialize all Firebase services.
  ///
  /// Returns `true` if initialization succeeded, `false` if running
  /// in demo/offline mode.
  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set up Crashlytics
      if (!kIsWeb) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Enable analytics collection
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

      _initialized = true;
      debugPrint('[AUCTE] Firebase initialized successfully.');
      return true;
    } catch (e) {
      debugPrint('[AUCTE] Firebase init failed — running in demo mode: $e');
      _initialized = false;
      return false;
    }
  }
}
