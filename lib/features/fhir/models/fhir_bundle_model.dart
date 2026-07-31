/// AUCTE — FHIR Bundle Model.
library;

import 'bundle_entry_model.dart';
import 'bundle_metadata_model.dart';
import 'fhir_resource.dart';

class FhirBundleModel extends FhirResource {
  const FhirBundleModel({
    required this.id,
    this.type = 'collection',
    required this.timestamp,
    required this.metadata,
    required this.total,
    required this.entries,
  });

  final String id;
  final String type;
  final DateTime timestamp;
  final BundleMetadataModel metadata;
  final int total;
  final List<BundleEntryModel> entries;

  @override
  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Bundle',
      'id': id,
      'meta': {
        'profile': [metadata.profileVersion],
        'lastUpdated': FhirResource.formatFhirDateTime(timestamp),
      },
      'identifier': {
        'system': 'urn:ietf:rfc:3986',
        'value': metadata.identifier,
      },
      'type': type,
      'timestamp': FhirResource.formatFhirDateTime(timestamp),
      'total': total,
      'entry': entries.map((e) => e.toJson()).toList(),
    };
  }
}
