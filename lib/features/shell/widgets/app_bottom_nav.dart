/// AUCTE — Floating bottom navigation bar.
///
/// Premium white floating pill with 5 tabs and subtle scale animations.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.bottomNavMarginH,
        right: AppSpacing.bottomNavMarginH,
        bottom: AppSpacing.bottomNavMarginV,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.bottomNavRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                selectedIcon: Icons.menu_book_rounded,
                label: 'Terminology',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.medical_services_outlined,
                selectedIcon: Icons.medical_services_rounded,
                label: 'Clinical',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.api_outlined,
                selectedIcon: Icons.api_rounded,
                label: 'FHIR',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.bottomNavRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCirc,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20.0 : 12.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryTeal.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.bottomNavRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.primaryTeal : AppColors.grey500,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
