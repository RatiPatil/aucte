/// AUCTE — Responsive layout builder.
///
/// Provides phone / tablet / desktop breakpoint-aware layout.
/// Wraps [LayoutBuilder] and exposes the current [ScreenType].
library;

import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_spacing.dart';

enum ScreenType { phone, tablet, desktop }

class AucteResponsiveLayout extends StatelessWidget {
  const AucteResponsiveLayout({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  /// Required layout for phone screens (< 600px).
  final Widget phone;

  /// Optional layout for tablet screens (600–1200px).
  /// Falls back to [phone] if not provided.
  final Widget? tablet;

  /// Optional layout for desktop screens (> 1200px).
  /// Falls back to [tablet] ?? [phone] if not provided.
  final Widget? desktop;

  /// Returns the current [ScreenType] based on [width].
  static ScreenType screenType(double width) {
    if (width >= AppConfig.tabletBreakpoint) return ScreenType.desktop;
    if (width >= AppConfig.mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.phone;
  }

  /// Returns the appropriate horizontal page padding.
  static double pagePadding(double width) {
    return switch (screenType(width)) {
      ScreenType.phone => AppSpacing.pagePaddingMobile,
      ScreenType.tablet => AppSpacing.pagePaddingTablet,
      ScreenType.desktop => AppSpacing.pagePaddingDesktop,
    };
  }

  /// Returns the number of grid columns for the given width.
  static int gridColumns(double width) {
    return switch (screenType(width)) {
      ScreenType.phone => 1,
      ScreenType.tablet => 2,
      ScreenType.desktop => 3,
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = screenType(constraints.maxWidth);

        return switch (type) {
          ScreenType.desktop => desktop ?? tablet ?? phone,
          ScreenType.tablet => tablet ?? phone,
          ScreenType.phone => phone,
        };
      },
    );
  }
}
