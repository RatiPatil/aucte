/// AUCTE Design System — Typography.
///
/// Professional healthcare typography using Inter exclusively for a
/// soft, clean, premium feel matching Apple/Google Health.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  /// Builds a complete [TextTheme] using Inter for all styles.
  static TextTheme textTheme(Brightness brightness) {
    final Color textColor =
        brightness == Brightness.light
            ? const Color(0xFF212121)
            : const Color(0xFFE0E0E0);

    final Color secondaryColor =
        brightness == Brightness.light
            ? const Color(0xFF757575)
            : const Color(0xFFBDBDBD);

    return TextTheme(
      // ── Display ─────────────────────────────────────────────
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: textColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),

      // ── Headline ────────────────────────────────────────────
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textColor,
      ),

      // ── Title ───────────────────────────────────────────────
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: textColor,
      ),

      // ── Body ────────────────────────────────────────────────
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: secondaryColor,
      ),

      // ── Label ───────────────────────────────────────────────
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: secondaryColor,
      ),
    );
  }
}
