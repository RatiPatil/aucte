/// AUCTE — Recent activity card.
///
/// List-tile style card for the recent activity section.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_medical_card.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.time,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AucteMedicalCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.pastelBlue,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
