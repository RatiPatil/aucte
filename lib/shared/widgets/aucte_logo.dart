import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AucteLogo extends StatelessWidget {
  const AucteLogo({super.key, this.size = 48, this.filled = true});

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(size * 0.29),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.health_and_safety_rounded,
        size: size * 0.55,
        color: filled ? AppColors.white : AppColors.primary,
      ),
    );
  }
}
