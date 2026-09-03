import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/shared_preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetOnboarding(BuildContext context) async {
    await SharedPreferencesService.instance.setBool(
      StorageKeys.onboardingCompleted,
      false,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarding reset! Launching splash screen...'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.splash,
      (route) => false,
    );
  }

  Future<void> _clearLocalSession(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset All Local Demo Data?'),
          content: const Text(
            'This will clear local patient lists, encounters, and session preferences.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Reset Data'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await SharedPreferencesService.instance.clear();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local demo data reset completely.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.splash,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Demo Dataset & Storage',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(
                        Icons.dataset_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text('NAMASTE Demo Version'),
                      subtitle: Text(
                        '100 Demo Terms (40 Ayurveda, 30 Siddha, 30 Unani)',
                      ),
                      trailing: Text(
                        'demo-1.0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text('Reset Onboarding Flow'),
                      subtitle: const Text(
                        'Re-launch initial introductory screens',
                      ),
                      onTap: () => _resetOnboarding(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      title: const Text(
                        'Clear Local Demo Storage',
                        style: TextStyle(color: AppColors.error),
                      ),
                      subtitle: const Text(
                        'Wipe SharedPreferences patients & encounters',
                      ),
                      onTap: () => _clearLocalSession(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'About',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AUCTE — AYUSH Unified Clinical Terminology Engine',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A secure digital platform for AYUSH practitioners enabling '
                      'unified clinical terminology mapping across NAMASTE, '
                      'WHO ICD-11 TM2, and FHIR R4 standards.',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'IMPORTANT NOTICE: This application is designed for use '
                      'by qualified AYUSH practitioners. Clinical terminology '
                      'mappings must be verified against official NAMASTE and '
                      'WHO ICD-11 sources before real-world clinical use.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
