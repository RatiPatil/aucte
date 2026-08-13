import 'dart:convert';

class ConsentModel {
  const ConsentModel({
    required this.id,
    required this.patientId,
    this.encounterId,
    required this.practitionerId,
    required this.purpose,
    required this.status,
    required this.grantedAt,
    this.expiresAt,
    required this.version,
    required this.createdAt,
  });

  final String id;
  final String patientId;
  final String? encounterId;
  final String practitionerId;
  final String purpose;
  final String status; // 'granted', 'declined', 'revoked'
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final String version;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'encounterId': encounterId,
      'practitionerId': practitionerId,
      'purpose': purpose,
      'status': status,
      'grantedAt': grantedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'version': version,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ConsentModel.fromMap(Map<String, dynamic> map) {
    return ConsentModel(
      id: map['id']?.toString() ?? '',
      patientId: map['patientId']?.toString() ?? '',
      encounterId: map['encounterId']?.toString(),
      practitionerId: map['practitionerId']?.toString() ?? '',
      purpose:
          map['purpose']?.toString() ?? 'Clinical Documentation & Dual Coding',
      status: map['status']?.toString() ?? 'granted',
      grantedAt:
          DateTime.tryParse(map['grantedAt']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(map['expiresAt']?.toString() ?? ''),
      version: map['version']?.toString() ?? '1.0',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ConsentModel.fromJson(String source) {
    return ConsentModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(source) as Map),
    );
  }

  ConsentModel copyWith({
    String? id,
    String? patientId,
    String? encounterId,
    String? practitionerId,
    String? purpose,
    String? status,
    DateTime? grantedAt,
    DateTime? expiresAt,
    String? version,
    DateTime? createdAt,
  }) {
    return ConsentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      encounterId: encounterId ?? this.encounterId,
      practitionerId: practitionerId ?? this.practitionerId,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      grantedAt: grantedAt ?? this.grantedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
