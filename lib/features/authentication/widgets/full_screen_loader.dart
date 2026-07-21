/// AUCTE — Full Screen Loader.
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      size: 40,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
