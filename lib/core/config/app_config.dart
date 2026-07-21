/// Application-wide configuration constants for AUCTE.
///
/// Centralizes all magic strings, version info, and feature flags
/// so nothing is hardcoded across the codebase.
library;

class AppConfig {
  AppConfig._();

  // ── App Identity ──────────────────────────────────────────────
  static const String appName = 'AUCTE';
  static const String appFullName = 'Ayush Unified Clinical Terminology Engine';
  static const String appTagline = 'FHIR-Compliant AYUSH Clinical Platform';
  static const String appOrg = 'Ministry of Ayush, Government of India';

  // ── Version ───────────────────────────────────────────────────
  static const String appVersion = '1.0.0';
  static const String buildPhase = 'Phase 1 — Application Shell';

  // ── Feature Flags ─────────────────────────────────────────────
  static const bool isFirebaseEnabled = true;
  static const bool isDemoMode = true; // Until Firebase project is linked

  // ── Responsive Breakpoints ────────────────────────────────────
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  // ── Animation Durations ───────────────────────────────────────
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration fadeInDuration = Duration(milliseconds: 1500);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  // ── Links ─────────────────────────────────────────────────────
  static const String privacyPolicyUrl = 'https://ayush.gov.in/privacy';
  static const String termsUrl = 'https://ayush.gov.in/terms';
  static const String helpUrl = 'https://ayush.gov.in/help';
}
