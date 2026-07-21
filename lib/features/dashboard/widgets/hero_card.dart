/// AUCTE — Hero Card.
///
/// Large primary-colored card for the main CTA.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_medical_card.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.onTap,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AucteMedicalCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryTeal,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryTeal,
                      minimumSize: const Size(120, 44),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    ),
                    child: Text(buttonLabel),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white24,
              size: 80,
            ),
          ],
        ),
      ),
    );
  }
}
