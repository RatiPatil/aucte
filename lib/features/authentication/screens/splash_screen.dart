/// AUCTE — Splash screen.
///
/// Government healthcare branding with fade-in animation.
/// Auto-navigates to login after the splash duration.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppConfig.fadeInDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto-navigate after splash duration
    Future.delayed(AppConfig.splashDuration, () {
      if (mounted) {
        context.goNamed(AppRouter.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxxl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // ── Government Emblem Placeholder ─────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      size: 40,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── App Name ──────────────────────────────────
                  Text(
                    AppConfig.appName,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTeal,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Full Name ─────────────────────────────────
                  Text(
                    AppConfig.appFullName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.grey400 : AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Tagline ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.xxl),
                    ),
                    child: Text(
                      AppConfig.appTagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Footer ────────────────────────────────────
                  Text(
                    AppConfig.appOrg,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.grey500 : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppConfig.buildPhase,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.grey600 : AppColors.grey400,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
