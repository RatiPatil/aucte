/// AUCTE — Settings screen.
///
/// Grouped settings with theme toggle, language, notifications,
/// and about section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_section_header.dart';
import '../../../shared/widgets/aucte_medical_card.dart';
import '../../../utils/extensions.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── General ─────────────────────────────────────
            const AucteSectionHeader(title: 'General'),
            AucteMedicalCard(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: isDark ? 'On' : 'Off',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () => context.showSnack(
                      'Language settings coming in Phase 2',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Notifications ───────────────────────────────
            const AucteSectionHeader(title: 'Notifications'),
            AucteMedicalCard(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: SettingsTile(
                icon: Icons.notifications_none_outlined,
                title: 'Push Notifications',
                subtitle: 'Enabled',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    context.showSnack('Notification settings coming in Phase 2');
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── About ───────────────────────────────────────
            const AucteSectionHeader(title: 'About'),
            AucteMedicalCard(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About ${AppConfig.appName}',
                    subtitle: AppConfig.appFullName,
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => context.showSnack('Opening privacy policy...'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () => context.showSnack('Opening terms of service...'),
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.code_outlined,
                    title: 'Version',
                    subtitle: '${AppConfig.appVersion} • ${AppConfig.buildPhase}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationLegalese: '© 2025 ${AppConfig.appOrg}\n\n${AppConfig.appTagline}',
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          'AUCTE is a government healthcare terminology platform designed '
          'to help AYUSH clinicians search standardized NAMASTE terminology, '
          'translate to WHO ICD-11, and generate FHIR resources.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
