/// AUCTE — Concept Map Model.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class ConceptMapModel {
  const ConceptMapModel({
    required this.namasteCode,
    required this.tm2Code,
    required this.icd11Code,
    required this.mappingType,
    required this.confidence,
    required this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  final String namasteCode;
  final String tm2Code;
  final String icd11Code;
  final String mappingType; // e.g., 'equivalent', 'broader', 'narrower'
  final String confidence; // e.g., 'High', 'Medium', 'Low'
  final String remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'namasteCode': namasteCode,
      'tm2Code': tm2Code,
      'icd11Code': icd11Code,
      'mappingType': mappingType,
      'confidence': confidence,
      'remarks': remarks,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ConceptMapModel.fromJson(Map<String, dynamic> json) {
    return ConceptMapModel(
      namasteCode: json['namasteCode'] as String? ?? '',
      tm2Code: json['tm2Code'] as String? ?? '',
      icd11Code: json['icd11Code'] as String? ?? '',
      mappingType: json['mappingType'] as String? ?? '',
      confidence: json['confidence'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
