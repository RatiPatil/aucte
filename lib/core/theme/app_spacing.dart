/// AUCTE Design System — Spacing constants.
///
/// 4px base-unit grid system with new premium 22px/24px card sizes.
library;

class AppSpacing {
  AppSpacing._();

  // ── Base Unit ─────────────────────────────────────────────────
  static const double unit = 4.0;

  // ── Named Spacers ─────────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
  static const double colossal = 64.0;

  // ── Card Specific ─────────────────────────────────────────────
  static const double cardPadding = 24.0;
  static const double cardRadius = 22.0;
  static const double cardElevation = 0.0;

  // ── Search & Input ────────────────────────────────────────────
  static const double searchBarHeight = 54.0;
  static const double inputRadius = 27.0; // Half of 54px for perfect pill

  // ── Bottom Navigation ─────────────────────────────────────────
  static const double bottomNavRadius = 28.0;
  static const double bottomNavMarginH = 20.0;
  static const double bottomNavMarginV = 16.0;

  // ── Page Margins ──────────────────────────────────────────────
  static const double pagePaddingMobile = 20.0;
  static const double pagePaddingTablet = 32.0;
  static const double pagePaddingDesktop = 40.0;

  // ── Icon Sizes ────────────────────────────────────────────────
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ── Avatar Sizes ──────────────────────────────────────────────
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 72.0;
  static const double avatarXl = 96.0;
}
