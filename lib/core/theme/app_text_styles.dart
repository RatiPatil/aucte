import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get displayLarge => TextStyle(
    fontFamily: 'Inter',
    fontSize: 34,
    height: 1.08,
    fontWeight: FontWeight.w900,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    height: 1.12,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.7,
    color: AppColors.textPrimary,
  );

  static TextStyle get headingLarge => TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static TextStyle get headingMedium => TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle get headingSmall => TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get overline => TextStyle(
    fontFamily: 'Inter',
    fontSize: 9,
    letterSpacing: 1.1,
    fontWeight: FontWeight.w800,
    color: AppColors.textSecondary,
  );

  static TextStyle get orangeLabel => TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static TextStyle get button => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
  );

  static TextStyle get code => TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 11,
    height: 1.55,
    color: AppColors.codeText,
  );
}
