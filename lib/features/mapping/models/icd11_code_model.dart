/// AUCTE — ICD-11 Code Model.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class ICD11CodeModel {
  const ICD11CodeModel({
    required this.code,
    required this.title,
    required this.definition,
    required this.chapter,
    this.createdAt,
    this.updatedAt,
  });

  final String code;
  final String title;
  final String definition;
  final String chapter;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'definition': definition,
      'chapter': chapter,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ICD11CodeModel.fromJson(Map<String, dynamic> json) {
    return ICD11CodeModel(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      chapter: json['chapter'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
