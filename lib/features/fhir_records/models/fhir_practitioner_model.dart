import 'dart:convert';
import '../../authentication/models/practitioner_model.dart';
import 'fhir_data_types.dart';

/// Standard FHIR R4 Practitioner Resource Model for AYUSH Doctors.
class FhirPractitionerModel {
  const FhirPractitionerModel({
    required this.id,
    this.resourceType = 'Practitioner',
    required this.identifiers,
    required this.name,
    required this.qualification,
    required this.ayushSystem,
    required this.institution,
    this.active = true,
  });

  final String id;
  final String resourceType;
  final List<FhirIdentifier> identifiers;
  final String name;
  final String qualification;
  final String ayushSystem;
  final String institution;
  final bool active;

  Map<String, dynamic> toFhirResource() {
    return {
      "resourceType": "Practitioner",
      "id": id,
      "active": active,
      "identifier": identifiers.map((id) => id.toMap()).toList(),
      "name": [
        {
          "use": "official",
          "text": name,
        },
      ],
      "qualification": [
        {
          "code": {
            "coding": [
              {
                "system": "https://aucte.ayush.gov.in/qualifications",
                "code": "ayush-specialist",
                "display": "AYUSH Specialist - $ayushSystem",
              },
            ],
            "text": qualification,
          },
          "issuer": {
            "display": institution,
          },
        },
      ],
    };
  }

  factory FhirPractitionerModel.fromPractitionerModel(PractitionerModel practitioner) {
    return FhirPractitionerModel(
      id: practitioner.id,
      identifiers: [
        FhirIdentifier(
          system: "https://aucte.ayush.gov.in/practitioner-id",
          value: practitioner.practitionerId,
          use: "official",
        ),
      ],
      name: practitioner.fullName,
      qualification: "AYUSH Specialist (${practitioner.ayushSystem})",
      ayushSystem: practitioner.ayushSystem,
      institution: practitioner.institution,
    );
  }

  factory FhirPractitionerModel.fromFhirMap(Map<String, dynamic> map) {
    final rawIdentifiers = map['identifier'] as List<dynamic>? ?? [];
    final identifiers = rawIdentifiers
        .map((i) => FhirIdentifier.fromMap(Map<String, dynamic>.from(i as Map)))
        .toList();

    String nameStr = '';
    final names = map['name'] as List<dynamic>? ?? [];
    if (names.isNotEmpty) {
      final nMap = names.first as Map<String, dynamic>;
      nameStr = nMap['text']?.toString() ?? '';
    }

    String qualStr = 'AYUSH Practitioner';
    String instStr = 'AYUSH Center';
    String systemStr = 'Ayurveda';

    final quals = map['qualification'] as List<dynamic>? ?? [];
    if (quals.isNotEmpty) {
      final qMap = quals.first as Map<String, dynamic>;
      final codeMap = qMap['code'] as Map<String, dynamic>?;
      qualStr = codeMap?['text']?.toString() ?? qualStr;
      final issuerMap = qMap['issuer'] as Map<String, dynamic>?;
      instStr = issuerMap?['display']?.toString() ?? instStr;

      final codings = codeMap?['coding'] as List<dynamic>? ?? [];
      if (codings.isNotEmpty) {
        final cMap = codings.first as Map<String, dynamic>;
        final display = cMap['display']?.toString() ?? '';
        if (display.contains('-')) {
          systemStr = display.split('-').last.trim();
        }
      }
    }

    return FhirPractitionerModel(
      id: map['id']?.toString() ?? '',
      identifiers: identifiers,
      name: nameStr,
      qualification: qualStr,
      ayushSystem: systemStr,
      institution: instStr,
      active: map['active'] as bool? ?? true,
    );
  }

  String toJsonString() => jsonEncode(toFhirResource());
}
