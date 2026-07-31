/// AUCTE — Enterprise Clinical Medical Card Widget.
///
/// Clean #FFFFFF surface container with 18px border radius, thin #E5E7EB border,
/// soft shadow, zero gradients, and 0.97 tap scale micro-interaction feedback.
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AucteMedicalCard extends StatefulWidget {
  const AucteMedicalCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? borderColor;

  @override
  State<AucteMedicalCard> createState() => _AucteMedicalCardState();
}

class _AucteMedicalCardState extends State<AucteMedicalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardContent = Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.borderColor ?? (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.borderLight),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
          onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
          onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
            child: widget.child,
          ),
        ),
      ),
    );

    final animatedCard = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _isPressed ? 0.97 : 1.0,
      curve: Curves.easeOutCubic,
      child: cardContent,
    );

    if (widget.margin != null) {
      return Padding(padding: widget.margin!, child: animatedCard);
    }
    return animatedCard;
  }
}
