import 'dart:convert';
import 'dart:io';

import 'package:aucte/core/routes/app_router.dart';
import 'package:aucte/core/services/shared_preferences_service.dart';
import 'package:aucte/core/theme/app_theme.dart';
import 'package:aucte/features/authentication/repositories/firebase_auth_repository.dart';
import 'package:aucte/features/encounters/screens/encounter_screen.dart';
import 'package:aucte/features/fhir_records/models/fhir_condition_model.dart';
import 'package:aucte/features/fhir_records/repositories/local_fhir_record_repository.dart';
import 'package:aucte/features/fhir_records/screens/fhir_preview_screen.dart';
import 'package:aucte/features/terminology/models/clinical_term_model.dart';
import 'package:aucte/features/terminology/repositories/local_terminology_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Synthetic diagnoses export as versioned problem-list codings', () {
    final dataset =
        jsonDecode(File('assets/data/namaste_demo.json').readAsStringSync())
            as Map<String, dynamic>;
    final terms = (dataset['terms'] as List).cast<Map<String, dynamic>>();
    final term = ClinicalTermModel.fromMap(
      terms.firstWhere((row) => row['system'] == 'Siddha'),
    );
    final condition = FhirConditionModel.fromClinicalTerm(term);
    final resource = condition.toFhirResource();
    expect(resource['category'][0]['coding'][0]['code'], 'problem-list-item');
    final codings = resource['code']['coding'] as List;
    expect(codings.map((coding) => coding['code']), [
      term.namasteCode,
      term.tm2Code,
      term.biomedicineCode,
    ]);
    expect(codings.every((coding) => coding['version'] == 'demo-2.0'), isTrue);
    expect(
      codings.every(
        (coding) =>
            (coding['system'] as String).startsWith('https://aucte.example/'),
      ),
      isTrue,
    );
    expect(FhirConditionModel.fromFhirMap(resource).term.system, 'Siddha');
    expect(FhirConditionModel.fromFhirMap(resource).term.isDemo, isTrue);
  });

  testWidgets('A sample encounter generates a Bundle after consent', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesService.instance.initialize();
    await FirebaseAuthRepository.instance.startDemoSession();
    await tester.runAsync(() async {
      await LocalTerminologyRepository.instance.getAllTerms();
      await LocalFhirRecordRepository.instance.getBundles();
    });
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 920);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const EncounterScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    Future<void> tapText(String text) async {
      final item = find.text(text).first;
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pumpAndSettle();
    }

    await tapText('NAMASTE Diagnosis & Dual Coding');
    await tapText('Jvara (Prathamika) (Ayurveda)');
    await tapText('Consent & Generation');
    final consent = find.widgetWithText(
      CheckboxListTile,
      'Patient Informed Consent Granted',
    );
    expect(tester.widget<CheckboxListTile>(consent).value, isFalse);
    await tapText('Patient Informed Consent Granted');
    await tapText('Generate FHIR Record');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.byType(FhirPreviewScreen), findsOneWidget);
    final bundles = await LocalFhirRecordRepository.instance.getBundles();
    expect(bundles.single.patient.id, 'AUC-PAT-1001');
    expect(bundles.single.isDualCoded, isTrue);
    expect(bundles.single.consent?.status, 'active');
    expect(bundles.single.consent?.category.coding.single.code, '59284-0');
  });
}
