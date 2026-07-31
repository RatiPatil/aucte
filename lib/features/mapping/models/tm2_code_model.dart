/// AUCTE — TM2 Code Model.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class TM2CodeModel {
  const TM2CodeModel({
    required this.code,
    required this.title,
    required this.definition,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  final String code;
  final String title;
  final String definition;
  final String category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'definition': definition,
      'category': category,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory TM2CodeModel.fromJson(Map<String, dynamic> json) {
    return TM2CodeModel(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      category: json['category'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
