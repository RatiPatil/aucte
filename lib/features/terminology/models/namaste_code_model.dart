/// AUCTE — NAMASTE Code Model.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class NamasteCodeModel {
  const NamasteCodeModel({
    required this.code,
    required this.name,
    required this.system,
    required this.category,
    required this.definition,
    required this.synonyms,
    required this.isActive,
    this.nameSearch = '',
    this.createdAt,
    this.updatedAt,
  });

  final String code;
  final String name;
  final String system;
  final String category;
  final String definition;
  final List<String> synonyms;
  final bool isActive;
  final String nameSearch; // For case-insensitive prefix search
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'system': system,
      'category': category,
      'definition': definition,
      'synonyms': synonyms,
      'isActive': isActive,
      'nameSearch': nameSearch.isEmpty ? name.toLowerCase() : nameSearch,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory NamasteCodeModel.fromJson(Map<String, dynamic> json) {
    return NamasteCodeModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      system: json['system'] as String? ?? '',
      category: json['category'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      synonyms: (json['synonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
      nameSearch: json['nameSearch'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  NamasteCodeModel copyWith({
    String? code,
    String? name,
    String? system,
    String? category,
    String? definition,
    List<String>? synonyms,
    bool? isActive,
    String? nameSearch,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NamasteCodeModel(
      code: code ?? this.code,
      name: name ?? this.name,
      system: system ?? this.system,
      category: category ?? this.category,
      definition: definition ?? this.definition,
      synonyms: synonyms ?? this.synonyms,
      isActive: isActive ?? this.isActive,
      nameSearch: nameSearch ?? this.nameSearch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
