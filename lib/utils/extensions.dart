/// AUCTE — Dart extensions.
library;

import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext].
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show a snackbar.
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}

/// Date formatting without external dependencies.
extension DateTimeExtensions on DateTime {
  /// Returns a human-readable date string, e.g. "20 Jul 2026".
  String get formatted => '$day ${_monthName(month)} $year';

  /// Returns greeting based on hour.
  String get greeting {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}
