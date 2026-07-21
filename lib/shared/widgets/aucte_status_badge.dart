/// AUCTE — Status badge widget.
///
/// Colored chip for displaying status (Active, Pending, Inactive).
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum AucteStatus { active, pending, inactive }

class AucteStatusBadge extends StatelessWidget {
  const AucteStatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  final AucteStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, defaultLabel) = switch (status) {
      AucteStatus.active => (
        AppColors.activeGreen,
        AppColors.activeGreenText,
        'Active',
      ),
      AucteStatus.pending => (
        AppColors.pendingAmber,
        AppColors.pendingAmberText,
        'Pending',
      ),
      AucteStatus.inactive => (
        AppColors.inactiveGrey,
        AppColors.inactiveGreyText,
        'Inactive',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        label ?? defaultLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
