import 'package:aucte/core/services/shared_preferences_service.dart';
import 'package:aucte/core/theme/app_theme.dart';
import 'package:aucte/features/authentication/repositories/firebase_auth_repository.dart';
import 'package:aucte/features/terminology/repositories/local_terminology_repository.dart';
import 'package:aucte/features/terminology/screens/terminology_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Finds and opens a sample mapping by its TM2 code', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesService.instance.initialize();
    await FirebaseAuthRepository.instance.startDemoSession();
    await tester.runAsync(LocalTerminologyRepository.instance.getAllTerms);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 920);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const TerminologySearchScreen()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'DEMO-TM2-AYU-101');
    await tester.pumpAndSettle();

    final result = find.text('Jvara (Prathamika)');
    expect(result, findsNWidgets(2));
    await tester.tap(result.first);
    await tester.pumpAndSettle();
    await tester.tap(result.last);
    await tester.pumpAndSettle();
    expect(find.text('WHO Ayurveda term (sample): Jvara'), findsOneWidget);
  });
}
