/// AUCTE — FHIR Bundle Entry Model.
library;

import 'fhir_resource.dart';

class BundleEntryModel {
  const BundleEntryModel({
    required this.fullUrl,
    required this.resource,
  });

  final String fullUrl;
  final FhirResource resource;

  Map<String, dynamic> toJson() {
    return {
      'fullUrl': fullUrl,
      'resource': resource.toJson(),
    };
  }
}
