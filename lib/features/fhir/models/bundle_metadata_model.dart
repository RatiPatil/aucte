/// AUCTE — FHIR Bundle Metadata Model.
library;

class BundleMetadataModel {
  const BundleMetadataModel({
    required this.bundleId,
    this.bundleType = 'collection',
    required this.timestamp,
    this.fhirVersion = '4.0.1',
    this.generator = 'AUCTE v1.0.0 (Ayush Clinical Terminology Engine)',
    required this.identifier,
    this.profileVersion = 'http://hl7.org/fhir/StructureDefinition/Bundle',
  });

  final String bundleId;
  final String bundleType;
  final DateTime timestamp;
  final String fhirVersion;
  final String generator;
  final String identifier;
  final String profileVersion;

  Map<String, dynamic> toJson() {
    return {
      'bundleId': bundleId,
      'bundleType': bundleType,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'fhirVersion': fhirVersion,
      'generator': generator,
      'identifier': identifier,
      'profileVersion': profileVersion,
    };
  }

  factory BundleMetadataModel.fromJson(Map<String, dynamic> json) {
    return BundleMetadataModel(
      bundleId: json['bundleId'] as String? ?? '',
      bundleType: json['bundleType'] as String? ?? 'collection',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      fhirVersion: json['fhirVersion'] as String? ?? '4.0.1',
      generator: json['generator'] as String? ?? 'AUCTE v1.0.0',
      identifier: json['identifier'] as String? ?? '',
      profileVersion: json['profileVersion'] as String? ??
          'http://hl7.org/fhir/StructureDefinition/Bundle',
    );
  }
}
