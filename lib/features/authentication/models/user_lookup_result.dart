/// AUCTE — User Lookup Result Model.
/// Distinguishes between document found, document missing, and network/timeout failures.
library;

import 'user_model.dart';

enum UserLookupStatus {
  found,
  notFound,
  timeout,
  networkError,
  permissionDenied,
  unknownError,
}

class UserLookupResult {
  const UserLookupResult._({
    required this.status,
    this.profile,
    this.errorMessage,
  });

  factory UserLookupResult.found(UserModel profile) {
    return UserLookupResult._(
      status: UserLookupStatus.found,
      profile: profile,
    );
  }

  factory UserLookupResult.notFound() {
    return const UserLookupResult._(
      status: UserLookupStatus.notFound,
    );
  }

  factory UserLookupResult.timeout() {
    return const UserLookupResult._(
      status: UserLookupStatus.timeout,
      errorMessage: 'Verification request timed out. Please check your connection.',
    );
  }

  factory UserLookupResult.networkError(String message) {
    return UserLookupResult._(
      status: UserLookupStatus.networkError,
      errorMessage: message,
    );
  }

  factory UserLookupResult.permissionDenied() {
    return const UserLookupResult._(
      status: UserLookupStatus.permissionDenied,
      errorMessage: 'Access denied to user database.',
    );
  }

  factory UserLookupResult.unknownError(String message) {
    return UserLookupResult._(
      status: UserLookupStatus.unknownError,
      errorMessage: message,
    );
  }

  final UserLookupStatus status;
  final UserModel? profile;
  final String? errorMessage;

  bool get isFound => status == UserLookupStatus.found && profile != null;
  bool get isNotFound => status == UserLookupStatus.notFound;
  bool get isFailed => !isFound && !isNotFound;
}
