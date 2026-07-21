/// AUCTE — Medical card widget.
///
/// Soft-shadow, rounded card used throughout the application.
/// Government healthcare style — white surface, no gradients.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class AucteMedicalCard extends StatelessWidget {
  const AucteMedicalCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? AppSpacing.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: padding ??
              const EdgeInsets.all(AppSpacing.cardPadding),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}
