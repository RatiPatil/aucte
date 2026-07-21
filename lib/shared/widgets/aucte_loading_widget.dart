/// AUCTE — Loading widget.
///
/// Centered spinner with an optional message.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class AucteLoadingWidget extends StatelessWidget {
  const AucteLoadingWidget({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
