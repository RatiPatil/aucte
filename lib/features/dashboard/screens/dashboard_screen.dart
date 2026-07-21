/// AUCTE — Dashboard screen.
///
/// Main home screen matching the premium healthcare reference design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_responsive_layout.dart';
import '../../../shared/widgets/aucte_search_bar.dart';
import '../../../shared/widgets/aucte_section_header.dart';
import '../../../utils/extensions.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/hero_card.dart';
import '../widgets/quick_service_item.dart';
import '../widgets/recent_activity_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('No user profile')));
        }
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
          final padding = AucteResponsiveLayout.pagePadding(constraints.maxWidth);
          final columns = AucteResponsiveLayout.gridColumns(constraints.maxWidth);

          return SafeArea(
            bottom: false, // Shell handles bottom padding
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, AppSpacing.lg, padding, 100), // Extra bottom padding for floating nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting Header ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${now.greeting},',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              user.displayName ?? 'Dr. Ayush Sharma',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'National Institute of Ayurveda',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded),
                            onPressed: () => context.showSnack('Notifications coming in Phase 2'),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceLight,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.pastelBlue,
                            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                            child: user.photoUrl == null
                                ? const Icon(Icons.person, color: AppColors.primaryTeal)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Search Bar ────────────────────────────────────
                  AucteSearchBar(
                    enabled: false,
                    onTap: () => context.showSnack('Terminology search coming in Phase 2'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Quick Services ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuickServiceItem(
                        title: 'Terminology',
                        icon: Icons.menu_book_rounded,
                        backgroundColor: AppColors.pastelBlue,
                        iconColor: AppColors.primaryTeal,
                        onTap: () => context.showSnack('Coming in Phase 2'),
                      ),
                      QuickServiceItem(
                        title: 'WHO TM2',
                        icon: Icons.language_rounded,
                        backgroundColor: AppColors.pastelGreen,
                        iconColor: AppColors.success,
                        onTap: () => context.showSnack('Coming in Phase 2'),
                      ),
                      QuickServiceItem(
                        title: 'ICD-11',
                        icon: Icons.medical_information_rounded,
                        backgroundColor: AppColors.pastelLavender,
                        iconColor: AppColors.accentPurple,
                        onTap: () => context.showSnack('Coming in Phase 2'),
                      ),
                      QuickServiceItem(
                        title: 'FHIR',
                        icon: Icons.data_object_rounded,
                        backgroundColor: AppColors.pastelCoral,
                        iconColor: AppColors.error,
                        onTap: () => context.showSnack('Coming in Phase 2'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Hero Card ─────────────────────────────────────
                  HeroCard(
                    title: 'Search AYUSH\nTerminology',
                    description: 'Explore standardized NAMASTE codes & WHO mapping.',
                    buttonLabel: 'Search Now',
                    onTap: () => context.showSnack('Coming in Phase 2'),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Feature Grid ──────────────────────────────────
                  GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.1, // Adjusted for slightly taller pastel cards
                    children: [
                      DashboardCard(
                        title: 'NAMASTE Explorer',
                        description: 'Browse codes',
                        icon: Icons.explore_rounded,
                        backgroundColor: AppColors.pastelBlue,
                        iconColor: AppColors.primaryTeal,
                        onTap: () => context.showSnack('Coming in Phase 2'),
                      ),
                      DashboardCard(
                        title: 'WHO TM2 Mapping',
                        description: 'Cross-reference',
                        icon: Icons.sync_alt_rounded,
                        backgroundColor: AppColors.pastelCream,
                        iconColor: AppColors.secondaryOrange,
                        onTap: () => context.showSnack('Coming in Phase 2'),
                      ),
                      DashboardCard(
                        title: 'FHIR Resources',
                        description: 'Generate bundles',
                        icon: Icons.api_rounded,
                        backgroundColor: AppColors.pastelLavender,
                        iconColor: AppColors.accentPurple,
                        onTap: () => context.showSnack('Coming in Phase 2'),
                      ),
                      DashboardCard(
                        title: 'Synchronization',
                        description: 'Central server',
                        icon: Icons.cloud_sync_rounded,
                        backgroundColor: AppColors.pastelGreen,
                        iconColor: AppColors.success,
                        onTap: () => context.showSnack('Coming in Phase 2'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Recent Activity ───────────────────────────────
                  const AucteSectionHeader(
                    title: 'Recent Encounters',
                    actionLabel: 'See All',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  ...List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: RecentActivityCard(
                        title: _recentActivities[index]['title']!,
                        subtitle: _recentActivities[index]['subtitle']!,
                        icon: _recentIcons[index],
                        time: _recentActivities[index]['time']!,
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Government Compliance Banner ────────────────
                  _ComplianceBanner(),
                ],
              ),
            ),
          );
        },
      ),
    );
  },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  static final _recentActivities = [
    {
      'title': 'Consultation: Raktamokshana',
      'subtitle': 'Patient ID: PT-8291',
      'time': 'Just now',
    },
    {
      'title': 'FHIR Bundle Generated',
      'subtitle': 'Mapped to WHO TM2',
      'time': '1 hr ago',
    },
    {
      'title': 'Terminology Synced',
      'subtitle': 'NAMASTE v2.1 Update',
      'time': '3 hrs ago',
    },
  ];

  static const _recentIcons = [
    Icons.medical_services_outlined,
    Icons.data_object_outlined,
    Icons.sync_outlined,
  ];
}

/// Government compliance banner at the bottom of the dashboard.
class _ComplianceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryTealDark.withValues(alpha: 0.2)
            : AppColors.complianceBgLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.primaryTeal,
            size: AppSpacing.iconLg,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Government Compliant',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'FHIR R4 • ABDM Compatible • WHO ICD-11 TM2',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.complianceTextDark : AppColors.complianceTextLight,
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
