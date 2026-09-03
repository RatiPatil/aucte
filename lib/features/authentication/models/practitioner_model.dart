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
    required this.createdAt,
    this.photoURL,
    this.provider = 'email',
    // password is kept as a local-only transient field and is NEVER
    // serialised to Firestore. It is only used by the local demo auth path.
    this.password = '',
  });

  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String practitionerId;
  final String ayushSystem;
  final String institution;
  final DateTime createdAt;

  /// Google/Firebase profile photo URL. Null for email-registered users.
  final String? photoURL;

  /// Authentication provider: 'google', 'email', or 'local'.
  final String provider;

  /// Local-only password. NEVER written to Firestore.
  final String password;

  /// Serialise for Firestore — password is intentionally excluded.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'practitionerId': practitionerId,
      'ayushSystem': ayushSystem,
      'institution': institution,
      'photoURL': photoURL,
      'provider': provider,
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
      photoURL: map['photoURL']?.toString(),
      provider: map['provider']?.toString() ?? 'email',
      // password is never read from Firestore — always empty
      password: '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  /// Serialise for local SharedPreferences storage (includes password for
  /// the local demo auth path only).
  Map<String, dynamic> toLocalMap() {
    return {
      ...toMap(),
      'password': password,
    };
  }

  String toJson() => jsonEncode(toLocalMap());

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
    DateTime? createdAt,
    String? photoURL,
    String? provider,
    String? password,
  }) {
    return PractitionerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      practitionerId: practitionerId ?? this.practitionerId,
      ayushSystem: ayushSystem ?? this.ayushSystem,
      institution: institution ?? this.institution,
      createdAt: createdAt ?? this.createdAt,
      photoURL: photoURL ?? this.photoURL,
      provider: provider ?? this.provider,
      password: password ?? this.password,
    );
  }
}
