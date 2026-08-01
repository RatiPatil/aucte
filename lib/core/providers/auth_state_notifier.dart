/// AUCTE — Unified Auth State Notifier.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

enum AppAuthState {
  loading,
  unauthenticated,
  authenticatedUnknown, // Logged into Firebase, but no Firestore document -> Route to Request Access
  authenticatedPending, // Firestore doc exists but approved == false -> Route to Pending Approval
  authenticatedAndApproved, // Authorized user -> Route to Workspace
  authVerificationError, // Timeout / network / permission error during lookup
}

final appAuthStateProvider = Provider<AppAuthState>((ref) {
  final firebaseAuthUser = ref.watch(firebaseAuthProvider);

  return firebaseAuthUser.when(
    data: (user) {
      if (user == null) return AppAuthState.unauthenticated;

      final lookupAsync = ref.watch(userLookupProvider);

      return lookupAsync.when(
        data: (result) {
          if (result.isNotFound) return AppAuthState.authenticatedUnknown;
          if (result.isFound && result.profile != null) {
            final profile = result.profile!;
            if (profile.approved) return AppAuthState.authenticatedAndApproved;
            return AppAuthState.authenticatedPending;
          }
          return AppAuthState.authVerificationError;
        },
        loading: () => AppAuthState.loading,
        error: (_, __) => AppAuthState.authVerificationError,
      );
    },
    loading: () => AppAuthState.loading,
    error: (_, __) => AppAuthState.unauthenticated,
  );
});
