/// AUCTE — Compliance Banner Widget.
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AucteComplianceBanner extends StatelessWidget {
  const AucteComplianceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.medicalGreen.withValues(alpha: 0.15)
            : AppColors.complianceBgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.medicalGreen.withValues(alpha: 0.3)
              : AppColors.complianceBorderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: isDark ? AppColors.complianceTextDark : AppColors.medicalGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FHIR R4 • ABDM Compliant • WHO TM2 Engine',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.complianceTextDark
                        : AppColors.medicalGreen,
                  ),
                ),
                Text(
                  'Ministry of Ayush Government Healthcare Platform Standards',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.complianceTextDark.withValues(alpha: 0.8)
                        : AppColors.medicalGreen.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
