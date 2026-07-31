/// AUCTE — FHIR Resource Base Class.
library;

import 'dart:convert';

enum FhirResourceType { condition, observation, procedure, medicationStatement }

abstract class FhirResource {
  const FhirResource();

  Map<String, dynamic> toJson();

  String toPrettyJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  /// Formats a DateTime into a strict FHIR R4 compliant ISO8601 string (with timezone offset)
  static String formatFhirDateTime(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String(); // .toUtc() forces the 'Z' timezone which is fully compliant.
  }
}
