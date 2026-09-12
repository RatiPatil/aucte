// File generated or configured for Firebase project setup.
// Replace the values below or overwrite this file with your FlutterFire CLI generated firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBksBZQBIBukHCfDjuU0cyZv4iF3mqrqx4',
    appId: '1:80730281294:web:9c613c5ba767781c1c3a1f',
    messagingSenderId: '80730281294',
    projectId: 'aucte-b89ad',
    authDomain: 'aucte-b89ad.firebaseapp.com',
    storageBucket: 'aucte-b89ad.firebasestorage.app',
    measurementId: 'G-6Y491E0007',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1MgO4bjQcbakHSvaOjf9L79CppeXb0Po',
    appId: '1:80730281294:android:b2951d907bbc6afc1c3a1f',
    messagingSenderId: '80730281294',
    projectId: 'aucte-b89ad',
    storageBucket: 'aucte-b89ad.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1MgO4bjQcbakHSvaOjf9L79CppeXb0Po',
    appId: '1:80730281294:ios:b2951d907bbc6afc1c3a1f',
    messagingSenderId: '80730281294',
    projectId: 'aucte-b89ad',
    storageBucket: 'aucte-b89ad.firebasestorage.app',
    iosBundleId: 'in.gov.ayush.aucte',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD1MgO4bjQcbakHSvaOjf9L79CppeXb0Po',
    appId: '1:80730281294:ios:b2951d907bbc6afc1c3a1f',
    messagingSenderId: '80730281294',
    projectId: 'aucte-b89ad',
    storageBucket: 'aucte-b89ad.firebasestorage.app',
    iosBundleId: 'in.gov.ayush.aucte',
  );
}

