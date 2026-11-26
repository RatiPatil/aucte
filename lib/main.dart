import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferencesService.instance.initialize();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  runApp(const AucteApp());
}
