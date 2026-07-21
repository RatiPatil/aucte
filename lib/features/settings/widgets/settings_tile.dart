/// AUCTE — Settings tile widget.
///
/// Reusable row for the settings screen.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: AppSpacing.iconMd),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                )
              : null),
      onTap: onTap,
    );
  }
}
