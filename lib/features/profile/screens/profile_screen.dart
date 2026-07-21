/// AUCTE — Profile screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_secondary_button.dart';
import '../../../shared/widgets/aucte_medical_card.dart';
import '../../../utils/extensions.dart';
import '../widgets/profile_info_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.showSnack('Profile editing coming in Phase 2'),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User profile not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Avatar ────────────────────────────────────────
                Stack(
                  children: [
                    CircleAvatar(
                      radius: AppSpacing.avatarXl / 2,
                      backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                      child: Text(
                        _initials(user.displayName),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Name ──────────────────────────────────────────
                Text(
                  user.displayName ?? 'Clinician',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  user.designation ?? 'AYUSH Practitioner',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Info Tiles ────────────────────────────────────
                AucteMedicalCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ProfileInfoTile(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: user.displayName ?? '—',
                      ),
                      const Divider(height: 1),
                      ProfileInfoTile(
                        icon: Icons.badge_outlined,
                        label: 'Designation',
                        value: user.designation ?? '—',
                      ),
                      const Divider(height: 1),
                      ProfileInfoTile(
                        icon: Icons.medical_services_outlined,
                        label: 'Department',
                        value: user.department ?? '—',
                      ),
                      const Divider(height: 1),
                      ProfileInfoTile(
                        icon: Icons.local_hospital_outlined,
                        label: 'Hospital',
                        value: user.hospital ?? '—',
                      ),
                      const Divider(height: 1),
                      ProfileInfoTile(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Role',
                        value: user.role.label,
                      ),
                      const Divider(height: 1),
                      ProfileInfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Edit Button ───────────────────────────────────
                AucteSecondaryButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_outlined,
                  onPressed: () => context.showSnack(
                    'Profile editing coming in Phase 2',
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // ── Version ───────────────────────────────────────
                Text(
                  '${AppConfig.appName} v${AppConfig.appVersion}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppConfig.buildPhase,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
