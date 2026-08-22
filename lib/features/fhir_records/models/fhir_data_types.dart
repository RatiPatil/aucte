import 'dart:convert';

/// Reusable standard FHIR R4 Coding datatype.
class FhirCoding {
  const FhirCoding({
    required this.system,
    required this.code,
    required this.display,
    this.version,
    this.userSelected,
  });

  final String system;
  final String code;
  final String display;
  final String? version;
  final bool? userSelected;

  Map<String, dynamic> toMap() {
    return {
      'system': system,
      'code': code,
      'display': display,
      if (version != null) 'version': version,
      if (userSelected != null) 'userSelected': userSelected,
    };
  }

  factory FhirCoding.fromMap(Map<String, dynamic> map) {
    return FhirCoding(
      system: map['system']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      display: map['display']?.toString() ?? '',
      version: map['version']?.toString(),
      userSelected: map['userSelected'] as bool?,
    );
  }

  String toJson() => jsonEncode(toMap());
}

/// Reusable standard FHIR R4 CodeableConcept datatype.
class FhirCodeableConcept {
  const FhirCodeableConcept({
    required this.coding,
    this.text,
  });

  final List<FhirCoding> coding;
  final String? text;

  Map<String, dynamic> toMap() {
    return {
      'coding': coding.map((c) => c.toMap()).toList(),
      if (text != null && text!.isNotEmpty) 'text': text,
    };
  }

  factory FhirCodeableConcept.fromMap(Map<String, dynamic> map) {
    final rawCoding = map['coding'] as List<dynamic>? ?? [];
    return FhirCodeableConcept(
      coding: rawCoding
          .map((c) => FhirCoding.fromMap(Map<String, dynamic>.from(c as Map)))
          .toList(),
      text: map['text']?.toString(),
    );
  }

  String toJson() => jsonEncode(toMap());
}

/// Reusable standard FHIR R4 Identifier datatype.
class FhirIdentifier {
  const FhirIdentifier({
    required this.system,
    required this.value,
    this.use,
    this.type,
  });

  final String system;
  final String value;
  final String? use;
  final FhirCodeableConcept? type;

  Map<String, dynamic> toMap() {
    return {
      'system': system,
      'value': value,
      if (use != null) 'use': use,
      if (type != null) 'type': type!.toMap(),
    };
  }

  factory FhirIdentifier.fromMap(Map<String, dynamic> map) {
    return FhirIdentifier(
      system: map['system']?.toString() ?? '',
      value: map['value']?.toString() ?? '',
      use: map['use']?.toString(),
      type: map['type'] != null
          ? FhirCodeableConcept.fromMap(
              Map<String, dynamic>.from(map['type'] as Map),
            )
          : null,
    );
  }
}

/// Reusable standard FHIR R4 Reference datatype.
class FhirReference {
  const FhirReference({
    required this.reference,
    this.display,
    this.type,
  });

  final String reference;
  final String? display;
  final String? type;

  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      if (display != null && display!.isNotEmpty) 'display': display,
      if (type != null && type!.isNotEmpty) 'type': type,
    };
  }

  factory FhirReference.fromMap(Map<String, dynamic> map) {
    return FhirReference(
      reference: map['reference']?.toString() ?? '',
      display: map['display']?.toString(),
      type: map['type']?.toString(),
    );
  }
}

/// Reusable standard FHIR R4 Period datatype.
class FhirPeriod {
  const FhirPeriod({
    this.start,
    this.end,
  });

  final DateTime? start;
  final DateTime? end;

  Map<String, dynamic> toMap() {
    return {
      if (start != null) 'start': start!.toIso8601String(),
      if (end != null) 'end': end!.toIso8601String(),
    };
  }

  factory FhirPeriod.fromMap(Map<String, dynamic> map) {
    return FhirPeriod(
      start: DateTime.tryParse(map['start']?.toString() ?? ''),
      end: DateTime.tryParse(map['end']?.toString() ?? ''),
    );
  }
}
