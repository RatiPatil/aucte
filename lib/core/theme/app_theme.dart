/// AUCTE Design System — Theme.
///
/// Material 3 ThemeData for light and dark modes, built from the
/// teal seed color with soft pastels, floating 22px cards, and pill shapes.
library;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // ── Light Theme ───────────────────────────────────────────────
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.light,
      surface: AppColors.surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.textTheme(Brightness.light),

      // ── AppBar ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.textTheme(
          Brightness.light,
        ).titleLarge,
      ),

      // ── Card ──────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: AppSpacing.cardElevation,
        shadowColor: Colors.black.withValues(alpha: 0.05), // Soft floating shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // ── Filled Button ─────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          textStyle: AppTypography.textTheme(
            Brightness.light,
          ).labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: AppColors.primaryTeal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          textStyle: AppTypography.textTheme(
            Brightness.light,
          ).labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input Decoration (Pill) ───────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.primaryTeal,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.textTheme(Brightness.light).bodyLarge
            ?.copyWith(color: AppColors.textDisabled),
      ),

      // ── Bottom Navigation Bar (Handled custom, base config here) ─
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ──────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(Brightness.dark),

      // ── AppBar ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFE0E0E0),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.textTheme(
          Brightness.dark,
        ).titleLarge,
      ),

      // ── Card ──────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: AppSpacing.cardElevation,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        color: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // ── Filled Button ─────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryTealLight,
          foregroundColor: AppColors.primaryTealDark,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          textStyle: AppTypography.textTheme(
            Brightness.dark,
          ).labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTealLight,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: AppColors.primaryTealLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          textStyle: AppTypography.textTheme(
            Brightness.dark,
          ).labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input Decoration (Pill) ───────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.primaryTealLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFF49454F),
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ──────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }
}
