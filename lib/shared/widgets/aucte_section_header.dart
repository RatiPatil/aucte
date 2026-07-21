/// AUCTE — Section header widget.
///
/// Bold title with an optional trailing action (e.g. "See All").
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class AucteSectionHeader extends StatelessWidget {
  const AucteSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
