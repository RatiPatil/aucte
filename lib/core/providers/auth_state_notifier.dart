/// AUCTE — Unified Auth State Notifier.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

enum AppAuthState {
  loading,
  unauthenticated,
  authenticatedUnknown, // Logged into Google, but no Firestore document
  authenticatedPending, // Firestore doc exists but approved == false
  authenticatedAndApproved,
}

final appAuthStateProvider = Provider<AppAuthState>((ref) {
  final firebaseAuthUser = ref.watch(firebaseAuthProvider);
  
  return firebaseAuthUser.when(
    data: (user) {
      if (user == null) return AppAuthState.unauthenticated;
      
      final firestoreUser = ref.watch(currentUserProvider);
      
      return firestoreUser.when(
        data: (profile) {
          if (profile == null) return AppAuthState.authenticatedUnknown;
          if (profile.approved) return AppAuthState.authenticatedAndApproved;
          return AppAuthState.authenticatedPending;
        },
        loading: () => AppAuthState.loading,
        error: (_, __) => AppAuthState.unauthenticated,
      );
    },
    loading: () => AppAuthState.loading,
    error: (_, __) => AppAuthState.unauthenticated,
  );
});
