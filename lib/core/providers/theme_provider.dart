/// AUCTE — Riverpod provider for theme mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the current [ThemeMode].
///
/// Defaults to [ThemeMode.system]. The Settings screen toggles
/// between light / dark / system.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  void setThemeMode(ThemeMode mode) => state = mode;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
