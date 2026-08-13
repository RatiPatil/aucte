import 'dart:convert';

class ClinicalTermModel {
  const ClinicalTermModel({
    required this.id,
    required this.namasteCode,
    required this.namasteTerm,
    required this.system,
    required this.description,
    required this.tm2Code,
    required this.tm2Title,
    required this.biomedicineCode,
    required this.biomedicineTitle,
    required this.mappingType,
    required this.mappingConfidence,
    required this.source,
    required this.isDemo,
  });

  final String id;
  final String namasteCode;
  final String namasteTerm;
  final String system;
  final String description;
  final String tm2Code;
  final String tm2Title;
  final String biomedicineCode;
  final String biomedicineTitle;
  final String mappingType;
  final double mappingConfidence;
  final String source;
  final bool isDemo;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namasteCode': namasteCode,
      'namasteTerm': namasteTerm,
      'system': system,
      'description': description,
      'tm2Code': tm2Code,
      'tm2Title': tm2Title,
      'biomedicineCode': biomedicineCode,
      'biomedicineTitle': biomedicineTitle,
      'mappingType': mappingType,
      'mappingConfidence': mappingConfidence,
      'source': source,
      'isDemo': isDemo,
    };
  }

  factory ClinicalTermModel.fromMap(Map<String, dynamic> map) {
    return ClinicalTermModel(
      id: map['id']?.toString() ?? '',
      namasteCode: map['namasteCode']?.toString() ?? '',
      namasteTerm: map['namasteTerm']?.toString() ?? '',
      system: map['system']?.toString() ?? 'Ayurveda',
      description: map['description']?.toString() ?? '',
      tm2Code: map['tm2Code']?.toString() ?? '',
      tm2Title: map['tm2Title']?.toString() ?? '',
      biomedicineCode: map['biomedicineCode']?.toString() ?? '',
      biomedicineTitle: map['biomedicineTitle']?.toString() ?? '',
      mappingType: map['mappingType']?.toString() ?? 'demo',
      mappingConfidence: (map['mappingConfidence'] as num?)?.toDouble() ?? 0.90,
      source: map['source']?.toString() ?? 'AUCTE SIH demonstration dataset',
      isDemo: map['isDemo'] as bool? ?? true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ClinicalTermModel.fromJson(String source) {
    return ClinicalTermModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(source) as Map),
    );
  }

  ClinicalTermModel copyWith({
    String? id,
    String? namasteCode,
    String? namasteTerm,
    String? system,
    String? description,
    String? tm2Code,
    String? tm2Title,
    String? biomedicineCode,
    String? biomedicineTitle,
    String? mappingType,
    double? mappingConfidence,
    String? source,
    bool? isDemo,
  }) {
    return ClinicalTermModel(
      id: id ?? this.id,
      namasteCode: namasteCode ?? this.namasteCode,
      namasteTerm: namasteTerm ?? this.namasteTerm,
      system: system ?? this.system,
      description: description ?? this.description,
      tm2Code: tm2Code ?? this.tm2Code,
      tm2Title: tm2Title ?? this.tm2Title,
      biomedicineCode: biomedicineCode ?? this.biomedicineCode,
      biomedicineTitle: biomedicineTitle ?? this.biomedicineTitle,
      mappingType: mappingType ?? this.mappingType,
      mappingConfidence: mappingConfidence ?? this.mappingConfidence,
      source: source ?? this.source,
      isDemo: isDemo ?? this.isDemo,
    );
  }
}
