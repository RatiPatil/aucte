/// AUCTE — Dashboard feature card.
///
/// Pastel-colored card for the dashboard grid.
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? backgroundColor.withValues(alpha: 0.15) : backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius / 1.5),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : iconColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : iconColor.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
