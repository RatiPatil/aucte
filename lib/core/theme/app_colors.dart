import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand (Digital Healthcare: Teal / Cyan palette)
  static const Color primary = Color(0xFF0096C7);
  static const Color primaryDark = Color(0xFF023E8A);
  static const Color primaryLight = Color(0xFF90E0EF);
  static const Color primarySoft = Color(0xFFCAF0F8);

  // Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF7F7F7);

  // Typography
  static const Color textPrimary = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF737373);
  static const Color textMuted = Color(0xFFA3A3A3);

  // UI
  static const Color border = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFF0F0F0);

  // Semantic
  static const Color success = Color(0xFF16A36A);
  static const Color successSoft = Color(0xFFEAF8F1);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF7E6);

  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFFEEEE);

  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFEEF4FF);

  // FHIR / code preview
  static const Color codeBackground = Color(0xFF181818);
  static const Color codeText = Color(0xFFF5F5F5);

  // Shadows
  static const Color shadow = Color(0x14000000);
  static const Color primaryShadow = Color(0x260096C7);
}
