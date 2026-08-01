/// AUCTE — GoRouter configuration.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/splash_screen.dart';
import '../../features/authentication/screens/request_access_screen.dart';
import '../../features/authentication/screens/pending_approval_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/fhir/screens/fhir_resources_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/shell/screens/app_shell.dart';
import '../../features/terminology/screens/namaste_explorer_screen.dart';
import '../../features/terminology/screens/terminology_detail_screen.dart';
import '../../features/terminology/screens/terminology_search_screen.dart';
import '../../features/mapping/screens/mapping_screen.dart';
import '../../features/fhir/screens/fhir_preview_screen.dart';
import '../../features/fhir/screens/fhir_bundle_preview_screen.dart';
import '../providers/auth_state_notifier.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = AppRouter.createRouter(ref);
  
  ref.listen(appAuthStateProvider, (previous, next) {
    if (previous != next) {
      router.refresh();
    }
  });
  
  return router;
});

class AppRouter {
  AppRouter._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String requestAccess = 'requestAccess';
  static const String pendingApproval = 'pendingApproval';
  static const String dashboard = 'dashboard';
  static const String terminology = 'terminology';
  static const String clinical = 'clinical';
  static const String fhir = 'fhir';
  static const String namasteExplorer = 'namasteExplorer';
  static const String terminologyDetail = 'terminologyDetail';
  static const String mapping = 'mapping';
  static const String fhirPreview = 'fhirPreview';
  static const String fhirBundle = 'fhirBundle';
  static const String profile = 'profile';
  static const String settings = 'settings';

  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String requestAccessPath = '/request-access';
  static const String pendingApprovalPath = '/pending-approval';
  static const String dashboardPath = '/dashboard';
  static const String terminologyPath = '/terminology';
  static const String clinicalPath = '/clinical';
  static const String fhirPath = '/fhir';
  static const String fhirBundlePath = '/fhir-bundle/:code';
  static const String namasteExplorerPath = '/namaste-explorer';
  static const String profilePath = '/profile';
  static const String settingsPath = '/settings';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: splashPath,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final path = state.uri.path;
        final authState = ref.read(appAuthStateProvider);
        
        final isLogin = path == loginPath;
        final isSplash = path == splashPath;
        
        if (authState == AppAuthState.loading) return null;
        
        if (authState == AppAuthState.unauthenticated) {
          if (!isLogin && !isSplash) return loginPath;
          return null;
        }
        
        if (authState == AppAuthState.authenticatedAndApproved) {
          if (isLogin || isSplash) return dashboardPath;
          return null;
        }
        
        if (authState == AppAuthState.authenticatedPending) {
          if (path != pendingApprovalPath) return pendingApprovalPath;
          return null;
        }
        
        if (authState == AppAuthState.authenticatedUnknown) {
          if (path != requestAccessPath) return requestAccessPath;
          return null;
        }

        if (authState == AppAuthState.authVerificationError) {
          if (!isLogin && !isSplash) return loginPath;
          return null;
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: splashPath,
          name: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: loginPath,
          name: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: requestAccessPath,
          name: requestAccess,
          builder: (context, state) => const RequestAccessScreen(),
        ),
        GoRoute(
          path: pendingApprovalPath,
          name: pendingApproval,
          builder: (context, state) => const PendingApprovalScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: dashboardPath,
              name: dashboard,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),
            GoRoute(
              path: terminologyPath,
              name: terminology,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TerminologySearchScreen(),
              ),
              routes: [
                GoRoute(
                  path: ':code',
                  name: terminologyDetail,
                  builder: (context, state) {
                    final code = state.pathParameters['code']!;
                    return TerminologyDetailScreen(code: code);
                  },
                  routes: [
                    GoRoute(
                      path: 'mapping',
                      name: mapping,
                      builder: (context, state) {
                        final code = state.pathParameters['code']!;
                        return MappingScreen(code: code);
                      },
                      routes: [
                        GoRoute(
                          path: 'fhirPreview',
                          name: fhirPreview,
                          builder: (context, state) {
                            final code = state.pathParameters['code']!;
                            return FhirPreviewScreen(code: code);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: namasteExplorerPath,
              name: namasteExplorer,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: NamasteExplorerScreen(),
              ),
            ),
            GoRoute(
              path: clinicalPath,
              name: clinical,
              pageBuilder: (context, state) => NoTransitionPage(
                child: _PlaceholderScreen(
                  title: 'Clinical Encounters',
                  icon: Icons.medical_services_outlined,
                  description: 'Clinical encounters will be available in Phase 2.',
                ),
              ),
            ),
            GoRoute(
              path: fhirPath,
              name: fhir,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: FhirResourcesScreen(),
              ),
            ),
            GoRoute(
              path: fhirBundlePath,
              name: fhirBundle,
              builder: (context, state) {
                final code = state.pathParameters['code'] ?? 'NA-01-01-001';
                return FhirBundlePreviewScreen(code: code);
              },
            ),
            GoRoute(
              path: profilePath,
              name: profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
            GoRoute(
              path: settingsPath,
              name: settings,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
