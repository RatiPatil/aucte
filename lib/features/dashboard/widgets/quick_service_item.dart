/// AUCTE — Quick Service Item.
///
/// Circular pastel icon with label for the quick services row.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class QuickServiceItem extends StatelessWidget {
  const QuickServiceItem({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
