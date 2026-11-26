import 'package:flutter/material.dart';

import '../../features/authentication/screens/login_screen.dart';
import '../../features/consent/screens/consent_screen.dart';
import '../../features/encounters/screens/encounter_screen.dart';
import '../../features/fhir_records/screens/fhir_preview_screen.dart';
import '../../features/mapping/screens/mapping_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/patients/screens/add_patient_screen.dart';
import '../../features/patients/screens/patient_detail_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/shell/screens/main_shell_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/terminology/screens/terminology_search_screen.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(const SplashScreen(), settings);

      case AppRoutes.onboarding:
        return _slideRoute(const OnboardingScreen(), settings);

      case AppRoutes.login:
        return _fadeRoute(const LoginScreen(), settings);

      case AppRoutes.register:
        return _fadeRoute(const LoginScreen(), settings);

      case AppRoutes.dashboard:
        return _fadeRoute(const MainShellScreen(initialIndex: 0), settings);

      case AppRoutes.patients:
        return _slideRoute(const MainShellScreen(initialIndex: 1), settings);

      case AppRoutes.addPatient:
        return _slideRoute(const AddPatientScreen(), settings);

      case AppRoutes.patientDetail:
        return _slideRoute(const PatientDetailScreen(), settings);

      case AppRoutes.terminology:
        return _slideRoute(const MainShellScreen(initialIndex: 2), settings);

      case AppRoutes.terminologySearch:
        return _slideRoute(const TerminologySearchScreen(), settings);

      case AppRoutes.mapping:
        return _slideRoute(const MappingScreen(), settings);

      case AppRoutes.encounter:
        return _slideRoute(const EncounterScreen(), settings);

      case AppRoutes.consent:
        return _slideRoute(const ConsentScreen(), settings);

      case AppRoutes.fhirRecords:
        return _slideRoute(const MainShellScreen(initialIndex: 3), settings);

      case AppRoutes.fhirPreview:
        return _slideRoute(const FhirPreviewScreen(), settings);

      case AppRoutes.profile:
        return _slideRoute(const MainShellScreen(initialIndex: 4), settings);

      case AppRoutes.settings:
        return _slideRoute(const SettingsScreen(), settings);

      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
    }
  }

  static PageRouteBuilder<dynamic> _fadeRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<dynamic> _slideRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
    );
  }
}
