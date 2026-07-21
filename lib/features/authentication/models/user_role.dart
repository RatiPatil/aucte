/// AUCTE — User Role enum.
library;

enum UserRole {
  superAdmin('Super Admin'),
  hospitalAdmin('Hospital Admin'),
  doctor('Doctor'),
  unknown('Unknown');

  const UserRole(this.label);
  final String label;

  factory UserRole.fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.unknown,
    );
  }
}
