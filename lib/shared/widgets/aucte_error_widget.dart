/// AUCTE — Error widget.
///
/// Displays an error icon, message, and retry button.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AucteErrorWidget extends StatelessWidget {
  const AucteErrorWidget({
    super.key,
    this.message = 'Something went wrong.',
    this.onRetry,
    this.icon,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: AppSpacing.colossal,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
