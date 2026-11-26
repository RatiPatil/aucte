import 'dart:convert';
import '../../patients/models/patient_model.dart';
import 'fhir_data_types.dart';

/// Standard FHIR R4 Patient Resource Model.
class FhirPatientModel {
  const FhirPatientModel({
    required this.id,
    this.resourceType = 'Patient',
    required this.identifiers,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.telecom,
    required this.address,
    this.active = true,
  });

  final String id;
  final String resourceType;
  final List<FhirIdentifier> identifiers;
  final String name;
  final String gender;
  final DateTime birthDate;
  final String telecom;
  final String address;
  final bool active;

  /// Helper getter for ABHA identifier if available
  String? get abhaNumber {
    try {
      final abhaId = identifiers.firstWhere(
        (id) => id.system.contains('ndhm') || id.system.contains('healthid'),
      );
      return abhaId.value;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toFhirResource() {
    return {
      "resourceType": "Patient",
      "id": id,
      "active": active,
      "identifier": identifiers.map((id) => id.toMap()).toList(),
      "name": [
        {
          "use": "official",
          "text": name,
        },
      ],
      "gender": gender.toLowerCase() == 'male'
          ? 'male'
          : gender.toLowerCase() == 'female'
              ? 'female'
              : 'other',
      "birthDate": birthDate.toIso8601String().split('T')[0],
      "telecom": [
        {
          "system": "phone",
          "value": telecom,
          "use": "mobile",
        },
      ],
      "address": [
        {
          "use": "home",
          "line": [address],
          "country": "India",
        },
      ],
    };
  }

  factory FhirPatientModel.fromPatientModel(PatientModel patient) {
    final identifiers = <FhirIdentifier>[];

    if (patient.abhaNumber != null && patient.abhaNumber!.isNotEmpty) {
      identifiers.add(
        FhirIdentifier(
          system: "https://healthid.ndhm.gov.in",
          value: patient.abhaNumber!,
          use: "official",
        ),
      );
    }

    if (patient.aadhaarNumber != null && patient.aadhaarNumber!.isNotEmpty) {
      identifiers.add(
        FhirIdentifier(
          system: "https://uidai.gov.in",
          value: patient.aadhaarNumber!,
          use: "secondary",
        ),
      );
    }

    identifiers.add(
      FhirIdentifier(
        system: "https://aucte.ayush.gov.in/patient-id",
        value: patient.id,
        use: "usual",
      ),
    );

    return FhirPatientModel(
      id: patient.id,
      identifiers: identifiers,
      name: patient.fullName,
      gender: patient.gender,
      birthDate: patient.dateOfBirth,
      telecom: patient.mobile,
      address: "${patient.address}, ${patient.city}, ${patient.state}",
    );
  }

  factory FhirPatientModel.fromFhirMap(Map<String, dynamic> map) {
    final rawIdentifiers = map['identifier'] as List<dynamic>? ?? [];
    final identifiers = rawIdentifiers
        .map((i) => FhirIdentifier.fromMap(Map<String, dynamic>.from(i as Map)))
        .toList();

    String nameStr = '';
    final names = map['name'] as List<dynamic>? ?? [];
    if (names.isNotEmpty) {
      final nameMap = names.first as Map<String, dynamic>;
      nameStr = nameMap['text']?.toString() ?? '';
    }

    String phone = '';
    final telecoms = map['telecom'] as List<dynamic>? ?? [];
    if (telecoms.isNotEmpty) {
      final tMap = telecoms.first as Map<String, dynamic>;
      phone = tMap['value']?.toString() ?? '';
    }

    String addrStr = '';
    final addresses = map['address'] as List<dynamic>? ?? [];
    if (addresses.isNotEmpty) {
      final aMap = addresses.first as Map<String, dynamic>;
      final lines = aMap['line'] as List<dynamic>? ?? [];
      addrStr = lines.isNotEmpty ? lines.first.toString() : '';
    }

    return FhirPatientModel(
      id: map['id']?.toString() ?? '',
      identifiers: identifiers,
      name: nameStr,
      gender: map['gender']?.toString() ?? 'other',
      birthDate: DateTime.tryParse(map['birthDate']?.toString() ?? '') ??
          DateTime(1990, 1, 1),
      telecom: phone,
      address: addrStr,
      active: map['active'] as bool? ?? true,
    );
  }

  String toJsonString() => jsonEncode(toFhirResource());
}
