import 'dart:convert';
import 'dart:io';

import 'package:aucte/features/fhir_records/models/fhir_condition_model.dart';
import 'package:aucte/features/terminology/models/clinical_term_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Synthetic diagnoses export as versioned problem-list codings', () {
    final dataset = jsonDecode(
      File('assets/data/namaste_demo.json').readAsStringSync(),
    ) as Map<String, dynamic>;
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
}
