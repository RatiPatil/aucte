/// AUCTE — Application shell.
///
/// Persistent scaffold with floating bottom navigation and navigation drawer.
/// Wraps all authenticated screens via GoRouter's ShellRoute.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Required for floating nav to float over content
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex(context),
        onTap: (index) => _onNavTap(context, index),
      ),
      drawer: AppDrawer(
        currentRoute: GoRouterState.of(context).uri.toString(),
        onNavigate: (path) {
          Navigator.of(context).pop(); // Close drawer
          context.go(path);
        },
        onLogout: () {
          Navigator.of(context).pop();
          context.goNamed(AppRouter.login);
        },
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRouter.dashboardPath)) return 0;
    if (location.startsWith(AppRouter.terminologyPath)) return 1;
    if (location.startsWith(AppRouter.clinicalPath)) return 2;
    if (location.startsWith(AppRouter.fhirPath)) return 3;
    if (location.startsWith(AppRouter.profilePath)) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    final routes = [
      AppRouter.dashboardPath,
      AppRouter.terminologyPath,
      AppRouter.clinicalPath,
      AppRouter.fhirPath,
      AppRouter.profilePath,
    ];
    context.go(routes[index]);
  }
}

/// Demo mode banner shown when Firebase is not connected.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isDemoMode) return const SizedBox.shrink();

    return MaterialBanner(
      content: const Text('Running in Demo Mode — Firebase not connected'),
      leading: const Icon(Icons.info_outline, color: Colors.orange),
      backgroundColor: Colors.orange.withValues(alpha: 0.1),
      actions: [
        TextButton(
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text('DISMISS'),
        ),
      ],
    );
  }
}
