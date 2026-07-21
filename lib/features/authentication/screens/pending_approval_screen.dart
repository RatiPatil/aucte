/// AUCTE — Pending Approval Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_secondary_button.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.pastelCoral.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty_rounded,
                      size: 48,
                      color: AppColors.pastelCoral,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Approval Pending',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Your request for clinical access is currently under review by the hospital administration.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? AppColors.grey300 : AppColors.grey700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AucteSecondaryButton(
                    label: 'Sign Out',
                    onPressed: () {
                      ref.read(authServiceProvider).signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
