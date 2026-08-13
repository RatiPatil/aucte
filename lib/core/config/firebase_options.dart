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

  // TODO: Replace with your actual Firebase project credentials
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_aucte_16dcb_web_key',
    appId: '1:101335608189675273154:web:aucte16dcb',
    messagingSenderId: '101335608189675273154',
    projectId: 'aucte-16dcb',
    authDomain: 'aucte-16dcb.firebaseapp.com',
    storageBucket: 'aucte-16dcb.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_aucte_16dcb_android_key',
    appId: '1:101335608189675273154:android:aucte16dcb',
    messagingSenderId: '101335608189675273154',
    projectId: 'aucte-16dcb',
    storageBucket: 'aucte-16dcb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_aucte_16dcb_ios_key',
    appId: '1:101335608189675273154:ios:aucte16dcb',
    messagingSenderId: '101335608189675273154',
    projectId: 'aucte-16dcb',
    storageBucket: 'aucte-16dcb.appspot.com',
    iosBundleId: 'com.example.aucte',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_aucte_16dcb_macos_key',
    appId: '1:101335608189675273154:ios:aucte16dcb',
    messagingSenderId: '101335608189675273154',
    projectId: 'aucte-16dcb',
    storageBucket: 'aucte-16dcb.appspot.com',
    iosBundleId: 'com.example.aucte',
  );
}
