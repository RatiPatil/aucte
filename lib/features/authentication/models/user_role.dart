/// AUCTE — User Role enum for SIH25026 Government Clinical Engine.
library;

enum UserRole {
  doctor('Government Doctor'),
  terminologyAdmin('Terminology Admin'),
  systemAdmin('System Admin'),
  hospitalAdmin('Hospital Admin'),
  superAdmin('Super Admin'),
  unknown('Unknown');

  const UserRole(this.label);
  final String label;

  factory UserRole.fromString(String value) {
    final clean = value.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == clean || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.unknown,
    );
  }

  bool get isDoctor => this == UserRole.doctor;
  bool get isTerminologyAdmin => this == UserRole.terminologyAdmin || this == UserRole.superAdmin;
  bool get isSystemAdmin => this == UserRole.systemAdmin || this == UserRole.superAdmin;
}
