/// AUCTE — Navigation drawer.
///
/// Professional government-style drawer with all navigation items.
library;

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.onLogout,
  });

  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryTealDark.withValues(alpha: 0.2)
                    : AppColors.primaryTeal.withValues(alpha: 0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: AppColors.primaryTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppConfig.appName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTeal,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    AppConfig.appTagline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Navigation Items ──────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    title: 'Dashboard',
                    isSelected: currentRoute.startsWith(AppRouter.dashboardPath),
                    onTap: () => onNavigate(AppRouter.dashboardPath),
                  ),
                  _DrawerItem(
                    icon: Icons.medical_information_outlined,
                    selectedIcon: Icons.medical_information,
                    title: 'Terminology',
                    isSelected: currentRoute.startsWith(AppRouter.terminologyPath),
                    onTap: () => onNavigate(AppRouter.terminologyPath),
                  ),
                  _DrawerItem(
                    icon: Icons.data_object_outlined,
                    selectedIcon: Icons.data_object,
                    title: 'FHIR Resources',
                    isSelected: false,
                    onTap: () => onNavigate(AppRouter.dashboardPath),
                    badge: 'Phase 2',
                  ),
                  _DrawerItem(
                    icon: Icons.assessment_outlined,
                    selectedIcon: Icons.assessment,
                    title: 'Reports',
                    isSelected: false,
                    onTap: () => onNavigate(AppRouter.dashboardPath),
                    badge: 'Phase 2',
                  ),
                  const Divider(height: AppSpacing.xxl),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    title: 'Settings',
                    isSelected: currentRoute.startsWith(AppRouter.settingsPath),
                    onTap: () => onNavigate(AppRouter.settingsPath),
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    selectedIcon: Icons.info,
                    title: 'About',
                    isSelected: false,
                    onTap: () => onNavigate(AppRouter.settingsPath),
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    selectedIcon: Icons.help,
                    title: 'Help',
                    isSelected: false,
                    onTap: () => onNavigate(AppRouter.settingsPath),
                  ),
                  const Divider(height: AppSpacing.xxl),
                  _DrawerItem(
                    icon: Icons.logout,
                    selectedIcon: Icons.logout,
                    title: 'Logout',
                    isSelected: false,
                    onTap: onLogout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            // ── Footer ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'v${AppConfig.appVersion} • ${AppConfig.buildPhase}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.isDestructive = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final color = isDestructive
        ? AppColors.error
        : isSelected
            ? primaryColor
            : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: color,
          size: 22,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Text(
                  badge!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null,
        selected: isSelected,
        selectedTileColor: primaryColor.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        onTap: onTap,
      ),
    );
  }
}
