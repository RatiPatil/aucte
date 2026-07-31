/// AUCTE — FHIR Bundle History Model.
library;

class BundleHistoryModel {
  const BundleHistoryModel({
    required this.bundleId,
    required this.namasteCode,
    required this.generatedTime,
    required this.generatedBy,
    required this.validationStatus,
    required this.resourceCount,
    required this.jsonContent,
  });

  final String bundleId;
  final String namasteCode;
  final DateTime generatedTime;
  final String generatedBy;
  final String validationStatus;
  final int resourceCount;
  final String jsonContent;

  Map<String, dynamic> toJson() {
    return {
      'bundleId': bundleId,
      'namasteCode': namasteCode,
      'generatedTime': generatedTime.toUtc().toIso8601String(),
      'generatedBy': generatedBy,
      'validationStatus': validationStatus,
      'resourceCount': resourceCount,
      'jsonContent': jsonContent,
    };
  }

  factory BundleHistoryModel.fromJson(Map<String, dynamic> json) {
    return BundleHistoryModel(
      bundleId: json['bundleId'] as String? ?? '',
      namasteCode: json['namasteCode'] as String? ?? '',
      generatedTime: json['generatedTime'] != null
          ? DateTime.parse(json['generatedTime'] as String)
          : DateTime.now(),
      generatedBy: json['generatedBy'] as String? ?? 'Unknown Practitioner',
      validationStatus: json['validationStatus'] as String? ?? 'Valid',
      resourceCount: json['resourceCount'] as int? ?? 0,
      jsonContent: json['jsonContent'] as String? ?? '',
    );
  }
}
