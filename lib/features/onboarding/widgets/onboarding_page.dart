import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/shared_preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/widgets/aucte_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _continue(BuildContext context) async {
    await SharedPreferencesService.instance.setBool(
      StorageKeys.onboardingCompleted,
      true,
    );

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              const AucteLogo(size: 84),

              const SizedBox(height: 32),

              Text(
                'One clinical language.\nBetter connected care.',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayMedium,
              ),

              const SizedBox(height: 16),

              Text(
                'Search AYUSH terminology, explore '
                'NAMASTE and ICD-11 mappings, and build '
                'interoperable FHIR-ready clinical records.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),

              const Spacer(),

              PrimaryButton(
                label: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _continue(context),
              ),

              const SizedBox(height: 16),

              Text(
                'Demo prototype • Not for clinical use',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
