/// AUCTE — Root application widget.
///
/// Configures MaterialApp.router with theming, GoRouter,
/// and Riverpod state management.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class AucteApp extends ConsumerWidget {
  const AucteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      // ── Identity ────────────────────────────────────────────
      title: AppConfig.appFullName,
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────────
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      // ── Router ──────────────────────────────────────────────
      routerConfig: ref.watch(routerProvider),
    );
  }
}
