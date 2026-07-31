/// AUCTE Design System — Deep Purple Enterprise Healthcare Palette.
///
/// Enterprise Government Healthcare Palette:
/// - Primary Brand (Deep Purple): #6D28D9
/// - Primary Light: #F3E8FF
/// - Primary Dark: #4C1D95
/// - Accent (Medical Red): #C62828 (Errors / Failures ONLY)
/// - Accent Light: #FEE2E2
/// - Success: #16A34A (Validation & Upload Success ONLY)
/// - Info: #2563EB (Informational notes ONLY)
/// - Warning: #F59E0B
/// - Primary Background: #FFFFFF
/// - Surface: #FFFFFF
/// - Text Primary: #1E293B
/// - Text Secondary: #64748B
/// - Border: #E5E7EB
/// - Divider: #F1F5F9
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Brand — Deep Purple ─────────────────────────────────
  static const Color deepPurple = Color(0xFF6D28D9);
  static const Color primaryLight = Color(0xFFF3E8FF);
  static const Color primaryDark = Color(0xFF4C1D95);

  // Backward compatibility aliases
  static const Color darkOrange = deepPurple;
  static const Color burntOrange = deepPurple;
  static const Color primaryTeal = deepPurple;
  static const Color primaryTealLight = primaryLight;
  static const Color primaryTealDark = primaryDark;
  static const Color seedColor = deepPurple;

  // ── Dark Slate Typography & Secondary ──────────────────────────
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color deepSlate = darkSlate;
  static const Color secondaryOrange = deepPurple;

  // ── Surface & Background ──────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // ── Borders & Dividers ─────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color outline = Color(0xFFCBD5E1);

  // ── Accents & Semantic ────────────────────────────────────────
  static const Color medicalRed = Color(0xFFC62828);
  static const Color accentLight = Color(0xFFFEE2E2);
  static const Color error = medicalRed;

  static const Color medicalGreen = Color(0xFF16A34A);
  static const Color success = medicalGreen;

  static const Color informationBlue = Color(0xFF2563EB);
  static const Color info = informationBlue;

  static const Color warning = Color(0xFFF59E0B);

  // ── Neutrals & Text ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // ── Pastels Aliases (Soft Tint Fills) ─────────────────────────
  static const Color pastelOrange = Color(0xFFF3E8FF);
  static const Color pastelCoral = Color(0xFFFEE2E2);
  static const Color pastelBlue = Color(0xFFEFF6FF);
  static const Color pastelGreen = Color(0xFFF0FDF4);
  static const Color pastelPurple = Color(0xFFF3E8FF);
  static const Color pastelCream = Color(0xFFFFFBEB);

  // ── Status Badges ─────────────────────────────────────────────
  static const Color activeGreen = pastelGreen;
  static const Color activeGreenText = medicalGreen;
  static const Color pendingAmber = pastelCream;
  static const Color pendingAmberText = warning;
  static const Color inactiveGrey = Color(0xFFF1F5F9);
  static const Color inactiveGreyText = textSecondary;

  // ── Dashboard Card Accents ────────────────────────────────────
  static const Color accentPurple = deepPurple;
  static const Color accentOrange = deepPurple;

  // ── Compliance Banner ─────────────────────────────────────────
  static const Color complianceBgLight = pastelGreen;
  static const Color complianceBorderLight = Color(0xFFBBF7D0);
  static const Color complianceTextLight = medicalGreen;
  static const Color complianceTextDark = Color(0xFF4ADE80);
}
