import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/shared_preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/animated_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = SharedPreferencesService.instance;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 1900));

    if (!mounted) return;

    final onboardingCompleted =
        _storage.getBool(StorageKeys.onboardingCompleted) ?? false;

    final loggedIn = _storage.getBool(StorageKeys.isLoggedIn) ?? false;

    if (!onboardingCompleted) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    if (!loggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              left: -120,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.04),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AnimatedLogo(),

                    const SizedBox(height: 26),

                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppStrings.appFullName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingSmall,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      AppStrings.interoperability,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),

                    const SizedBox(height: 38),

                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Column(
                children: [
                  Text(
                    'MINISTRY OF AYUSH • PROTOTYPE',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'FHIR R4 • NAMASTE • ICD-11',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
