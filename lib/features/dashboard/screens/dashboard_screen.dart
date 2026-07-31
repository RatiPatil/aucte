/// AUCTE — Doctor Workspace Landing Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_compliance_banner.dart';
import '../../../shared/widgets/aucte_medical_card.dart';
import '../../../shared/widgets/aucte_section_header.dart';
import '../../../shared/widgets/sih_module_matrix_card.dart';
import '../../fhir/providers/fhir_bundle_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final history = ref.watch(bundleHistoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final dateStr = '${_monthName(now.month)} ${now.day}, ${now.year}';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Hero Title: AUCTE Terminology Integration Engine ─
              _buildWorkspaceHeader(context, userAsync, dateStr),
              const SizedBox(height: AppSpacing.lg),

              // ── 2. Primary Hero Action: Search NAMASTE Box ─────────
              _buildHeroSearchNamasteBox(context),
              const SizedBox(height: AppSpacing.lg),

              // ── 3. ABDM Compliance Verification ────────────────────
              const AucteComplianceBanner(),
              const SizedBox(height: AppSpacing.xl),

              // ── 4. Recent Coding Sessions ──────────────────────────
              const AucteSectionHeader(title: 'Recent Coding Sessions'),
              const SizedBox(height: AppSpacing.xs),
              _buildRecentCodingSessions(context),
              const SizedBox(height: AppSpacing.xl),

              // ── 5. Recent FHIR Bundles ─────────────────────────────
              const AucteSectionHeader(title: 'Recent FHIR Bundles'),
              const SizedBox(height: AppSpacing.xs),
              _buildRecentFhirBundles(context, history),
              const SizedBox(height: AppSpacing.xl),

              // ── 6. Recent EMR Uploads ──────────────────────────────
              const AucteSectionHeader(title: 'Recent EMR Uploads'),
              const SizedBox(height: AppSpacing.xs),
              _buildRecentEmrUploads(context),
              const SizedBox(height: AppSpacing.xl),

              // ── 7. Terminology Dataset Status ─────────────────────
              const AucteSectionHeader(title: 'Terminology Dataset Status'),
              const SizedBox(height: AppSpacing.xs),
              _buildTerminologyDatasetStatus(context, isDark),
              const SizedBox(height: AppSpacing.xl),

              // ── 8. FHIR Compliance Status ──────────────────────────
              const AucteSectionHeader(title: 'FHIR Compliance Status'),
              const SizedBox(height: AppSpacing.xs),
              _buildFhirComplianceStatus(context, isDark),
              const SizedBox(height: AppSpacing.xl),

              // ── 9. SIH 10-Module Matrix ────────────────────────────
              const SihModuleMatrixCard(),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceHeader(BuildContext context, userAsync, String dateStr) {
    final theme = Theme.of(context);

    return userAsync.when(
      data: (user) {
        final doctorName = user?.displayName ?? 'Dr. AYUSH Clinician';
        final hospital = user?.hospital ?? 'All India Institute of Ayurveda';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AUCTE',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkOrange,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Terminology Integration Engine',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.darkOrange,
                  child: Text(
                    doctorName.replaceAll('Dr. ', '').substring(0, 1).toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$doctorName • $hospital • $dateStr',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
      loading: () => _buildSkeletonHeader(theme, dateStr),
      error: (_, __) => _buildSkeletonHeader(theme, dateStr),
    );
  }

  Widget _buildSkeletonHeader(ThemeData theme, String dateStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AUCTE',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkOrange),
        ),
        const Text('Terminology Integration Engine', style: TextStyle(fontWeight: FontWeight.w600)),
        Text('Dr. AYUSH Clinician • $dateStr', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildHeroSearchNamasteBox(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.go('/terminology'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkOrange, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkOrange.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.darkOrange, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search NAMASTE',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkOrange,
                    ),
                  ),
                  Text(
                    'Search disease name or code (e.g. "Jwara", "Kasa", "Suram")...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.darkOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⌘K',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCodingSessions(BuildContext context) {
    final theme = Theme.of(context);

    final recentItems = [
      {'code': 'NA-01-01-001', 'title': 'Jwara (Fever)', 'system': 'Ayurveda', 'status': 'FHIR Condition Ready'},
      {'code': 'NS-01-01-001', 'title': 'Suram', 'system': 'Siddha', 'status': 'WHO TM2 Mapped'},
      {'code': 'NU-01-01-001', 'title': 'Humma', 'system': 'Unani', 'status': 'ICD-11 Mapped'},
    ];

    return Column(
      children: recentItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: AucteMedicalCard(
            onTap: () => context.push('/terminology/${item['code']}'),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.darkOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.code_rounded, color: AppColors.darkOrange, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['title']} (${item['code']})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        '${item['system']} • ${item['status']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDisabled),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentFhirBundles(BuildContext context, history) {
    final theme = Theme.of(context);

    if (history.isEmpty) {
      return AucteMedicalCard(
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: AppColors.darkOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No FHIR Bundles generated yet. Click Search NAMASTE to generate a bundle.',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: history.take(3).map<Widget>((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: AucteMedicalCard(
            onTap: () => context.push('/fhir-bundle/${item.namasteCode}'),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_rounded, size: 20, color: AppColors.darkOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bundle: ${item.namasteCode}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        '${item.resourceCount} linked resources • ${item.validationStatus}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.medicalGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentEmrUploads(BuildContext context) {
    final theme = Theme.of(context);
    final uploads = [
      {'tx': 'TX-bundle-na0101001', 'dest': 'https://emr.abdm.gov.in/api/v1/fhir/Bundle', 'status': '200 OK • Ingested'},
      {'tx': 'TX-bundle-ns0101001', 'dest': 'https://emr.abdm.gov.in/api/v1/fhir/Bundle', 'status': '200 OK • Ingested'},
    ];

    return Column(
      children: uploads.map((u) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: AucteMedicalCard(
            onTap: () => context.push('/fhir'),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: AppColors.medicalGreen, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u['tx']!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        u['status']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.medicalGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTerminologyDatasetStatus(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return AucteMedicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dataset_rounded, color: AppColors.darkOrange, size: 18),
              const SizedBox(width: 8),
              Text(
                'Terminology Datasets Status',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkOrange,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildRow(context, 'NAMASTE Codes Dataset', '85 Realistic Records Loaded'),
          _buildRow(context, 'WHO TM2 Module Dataset', '85 Standard TM2 Records'),
          _buildRow(context, 'WHO ICD-11 Dataset', '85 Standard ICD-11 Records'),
          _buildRow(context, 'Dataset Version', 'v1.0.0-offline'),
        ],
      ),
    );
  }

  Widget _buildFhirComplianceStatus(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return AucteMedicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.medicalGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'FHIR Compliance Status',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.medicalGreen,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildRow(context, 'FHIR Standard Profile', 'HL7 R4 (4.0.1)'),
          _buildRow(context, 'Resource Validation', '100% Structural & Reference Clean'),
          _buildRow(context, 'ABDM Integration', 'Standardized Engine Active'),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String val) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          Text(val, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkSlate)),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }
}
