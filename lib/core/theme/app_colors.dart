/// AUCTE Design System — Color Palette.
///
/// Premium Government Healthcare color scheme matching reference.
/// Features a teal primary, warm secondary, soft grey background,
/// and a complete pastel system for cards.
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary — Teal ─────────────────────────────────────────────
  static const Color primaryTeal = Color(0xFF0D838A);
  static const Color primaryTealLight = Color(0xFF2CB1B8);
  static const Color primaryTealDark = Color(0xFF075E63);

  // ── Seed (for Material 3 ColorScheme.fromSeed) ────────────────
  static const Color seedColor = primaryTeal;

  // ── Secondary — Warm Orange ───────────────────────────────────
  static const Color secondaryOrange = Color(0xFFF09A3E);

  // ── Surface / Background ──────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF4F6F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ── Pastels (Grid System) ─────────────────────────────────────
  static const Color pastelBlue = Color(0xFFE2F5F8);
  static const Color pastelCoral = Color(0xFFFDE8E8);
  static const Color pastelGreen = Color(0xFFE8F8EE);
  static const Color pastelLavender = Color(0xFFF3E8FF);
  static const Color pastelCream = Color(0xFFFFF4E5);

  // ── Neutral ───────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = secondaryOrange;
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  // ── Status Badge Colors ───────────────────────────────────────
  static const Color activeGreen = pastelGreen;
  static const Color activeGreenText = success;
  static const Color pendingAmber = pastelCream;
  static const Color pendingAmberText = warning;
  static const Color inactiveGrey = grey100;
  static const Color inactiveGreyText = grey600;

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Divider / Outline ─────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E0);
  static const Color outline = Color(0xFFC8C8C8);

  // ── Dashboard Card Accents ────────────────────────────────────
  static const Color accentPurple = Color(0xFF6A1B9A);
  static const Color accentOrange = secondaryOrange;

  // ── Compliance Banner ─────────────────────────────────────────
  static const Color complianceBgLight = pastelGreen;
  static const Color complianceBorderLight = Color(0xFFA5D6A7);
  static const Color complianceTextLight = Color(0xFF388E3C);
  static const Color complianceTextDark = Color(0xFF81C784);
}
