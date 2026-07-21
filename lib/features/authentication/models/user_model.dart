/// AUCTE — User Model.
library;

import 'user_role.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.unknown,
    this.approved = false,
    this.hospital,
    this.department,
    this.designation,
    this.medicalRegistrationNumber,
    this.phone,
    this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final bool approved;
  final String? hospital;
  final String? department;
  final String? designation;
  final String? medicalRegistrationNumber;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  static const empty = UserModel(uid: '', email: '');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? ''),
      approved: json['approved'] as bool? ?? false,
      hospital: json['hospital'] as String?,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      medicalRegistrationNumber: json['medicalRegistrationNumber'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      lastLogin: json['lastLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastLogin'] as int)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'approved': approved,
      'hospital': hospital,
      'department': department,
      'designation': designation,
      'medicalRegistrationNumber': medicalRegistrationNumber,
      'phone': phone,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastLogin': lastLogin?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    bool? approved,
    String? hospital,
    String? department,
    String? designation,
    String? medicalRegistrationNumber,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      approved: approved ?? this.approved,
      hospital: hospital ?? this.hospital,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      medicalRegistrationNumber: medicalRegistrationNumber ?? this.medicalRegistrationNumber,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }
}
