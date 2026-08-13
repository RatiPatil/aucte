import 'dart:convert';

class PractitionerModel {
  const PractitionerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.practitionerId,
    required this.ayushSystem,
    required this.institution,
    required this.password,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String practitionerId;
  final String ayushSystem;
  final String institution;

  // DEMO ONLY.
  // Never store plain-text passwords in production.
  final String password;

  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'practitionerId': practitionerId,
      'ayushSystem': ayushSystem,
      'institution': institution,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PractitionerModel.fromMap(Map<String, dynamic> map) {
    return PractitionerModel(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      mobile: map['mobile']?.toString() ?? '',
      practitionerId: map['practitionerId']?.toString() ?? '',
      ayushSystem: map['ayushSystem']?.toString() ?? '',
      institution: map['institution']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PractitionerModel.fromJson(String source) {
    return PractitionerModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(source) as Map),
    );
  }

  PractitionerModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? mobile,
    String? practitionerId,
    String? ayushSystem,
    String? institution,
    String? password,
    DateTime? createdAt,
  }) {
    return PractitionerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      practitionerId: practitionerId ?? this.practitionerId,
      ayushSystem: ayushSystem ?? this.ayushSystem,
      institution: institution ?? this.institution,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
