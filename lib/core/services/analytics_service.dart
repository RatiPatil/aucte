/// AUCTE — Analytics & Crashlytics service.
///
/// Wraps Firebase Analytics and Crashlytics in a single service
/// with no-op fallbacks when Firebase is not initialized.
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? get _analytics =>
      FirebaseConfig.isInitialized ? FirebaseAnalytics.instance : null;

  FirebaseCrashlytics? get _crashlytics =>
      (FirebaseConfig.isInitialized && !kIsWeb)
          ? FirebaseCrashlytics.instance
          : null;

  /// Firebase Analytics observer for GoRouter / Navigator.
  FirebaseAnalyticsObserver? get observer =>
      _analytics != null ? FirebaseAnalyticsObserver(analytics: _analytics!) : null;

  /// Log a named event.
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    await _analytics?.logEvent(name: name, parameters: params);
  }

  /// Log a screen view.
  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  /// Set the current user ID for analytics + crashlytics.
  Future<void> setUserId(String? userId) async {
    await _analytics?.setUserId(id: userId);
    await _crashlytics?.setUserIdentifier(userId ?? '');
  }

  /// Record a non-fatal error in Crashlytics.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    if (_crashlytics != null) {
      await _crashlytics!.recordError(exception, stack, reason: reason);
    } else {
      debugPrint('[AUCTE] Error (not reported): $exception');
    }
  }

  /// Log a custom key for crash context.
  Future<void> setCustomKey(String key, String value) async {
    await _crashlytics?.setCustomKey(key, value);
  }
}
