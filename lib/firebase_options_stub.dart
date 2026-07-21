/// Stub for Firebase options.
///
/// Replace this file by running:
///   flutterfire configure
///
/// This stub allows the app to compile without a linked Firebase project.
/// When [FirebaseConfig.initialize] catches the error from these
/// placeholder values, the app falls back to demo mode.
library;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '${defaultTargetPlatform.name}. Run `flutterfire configure` '
          'to generate firebase_options.dart.',
        );
    }
  }

  // ── Placeholder values — replace via `flutterfire configure` ──
  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'AIzaSyB85vwgs8S_Tm1Z19zwq9kNzi81XzVXvI8',
    appId: '1:311822393493:android:0000000000000000', // Update this if Android fails
    messagingSenderId: '311822393493',
    projectId: 'aucte-16dcb',
    storageBucket: 'aucte-16dcb.firebasestorage.app',
  );

  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: 'AIzaSyB85vwgs8S_Tm1Z19zwq9kNzi81XzVXvI8',
    appId: '1:311822393493:ios:0000000000000000',
    messagingSenderId: '311822393493',
    projectId: 'aucte-16dcb',
    storageBucket: 'aucte-16dcb.firebasestorage.app',
    iosBundleId: 'gov.ayush.aucte',
  );

  static const FirebaseOptions _web = FirebaseOptions(
    apiKey: 'AIzaSyB85vwgs8S_Tm1Z19zwq9kNzi81XzVXvI8',
    appId: '1:311822393493:web:5c86fff6b8e67ec323fb9c',
    messagingSenderId: '311822393493',
    projectId: 'aucte-16dcb',
    storageBucket: 'aucte-16dcb.firebasestorage.app',
    authDomain: 'aucte-16dcb.firebaseapp.com',
    measurementId: 'G-KW446C11TL',
  );
}
