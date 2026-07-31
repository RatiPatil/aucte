/// AUCTE — Clinical Summary (Terminology Detail Screen).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_medical_card.dart';
import '../../../shared/widgets/aucte_section_header.dart';
import '../models/namaste_code_model.dart';
import '../providers/terminology_providers.dart';

class TerminologyDetailScreen extends ConsumerWidget {
  const TerminologyDetailScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termAsync = ref.watch(terminologyDetailProvider(code));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NAMASTE Code Details'),
      ),
      body: termAsync.when(
        data: (term) {
          if (term == null) {
            return const Center(child: Text('Terminology record not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Clinical Summary Top Banner ─────────────────
                _buildClinicalHeader(context, term, isDark),
                const SizedBox(height: AppSpacing.md),

                // ── 2. Interoperability Chips ────────────────────────
                _buildInteroperabilityChips(context),
                const SizedBox(height: AppSpacing.xl),

                // ── 3. Clinical Definition ───────────────────────────
                const AucteSectionHeader(title: 'Clinical Definition'),
                const SizedBox(height: AppSpacing.xs),
                AucteMedicalCard(
                  child: Text(
                    term.definition.isEmpty
                        ? 'No formal clinical definition provided.'
                        : term.definition,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── 4. Clinical Synonyms ─────────────────────────────
                if (term.synonyms.isNotEmpty) ...[
                  const AucteSectionHeader(title: 'Clinical Synonyms & Aliases'),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: term.synonyms.map((syn) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.darkOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.darkOrange.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          syn,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.darkOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // ── 5. Interoperability Pipeline Timeline ─────────────
                const AucteSectionHeader(title: 'Clinical Interoperability Pipeline'),
                const SizedBox(height: AppSpacing.xs),
                _buildPipelineTimeline(context, term),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),

      // ── Sticky Bottom Action Bar ──────────────────────────────
      bottomSheet: termAsync.when(
        data: (term) => term != null ? _buildStickyActionBar(context, term.code) : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildClinicalHeader(BuildContext context, NamasteCodeModel term, bool isDark) {
    final theme = Theme.of(context);
    final englishName = term.synonyms.isNotEmpty ? term.synonyms.first : term.name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkOrange.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  term.code,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.darkOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkSlate.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  term.system,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            term.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.darkOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (englishName != term.name)
            Text(
              'English: $englishName',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Category: ${term.category}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteroperabilityChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _ChipBadge(label: 'Mapped', color: AppColors.medicalGreen, icon: Icons.check_circle_outline),
          SizedBox(width: 8),
          _ChipBadge(label: 'FHIR Ready', color: AppColors.darkOrange, icon: Icons.api_rounded),
          SizedBox(width: 8),
          _ChipBadge(label: 'WHO Linked', color: AppColors.informationBlue, icon: Icons.public_rounded),
          SizedBox(width: 8),
          _ChipBadge(label: 'ICD Linked', color: AppColors.accentPurple, icon: Icons.medical_services_outlined),
        ],
      ),
    );
  }

  Widget _buildPipelineTimeline(BuildContext context, NamasteCodeModel term) {
    return AucteMedicalCard(
      child: Column(
        children: [
          _buildStepRow(context, '1. NAMASTE', term.code, 'Indian AYUSH Terminology', AppColors.darkOrange),
          const Divider(height: 20),
          _buildStepRow(context, '2. WHO TM2', 'Linked', 'Traditional Medicine Module 2', AppColors.informationBlue),
          const Divider(height: 20),
          _buildStepRow(context, '3. ICD-11', 'Linked', 'International Classification', AppColors.accentPurple),
          const Divider(height: 20),
          _buildStepRow(context, '4. FHIR R4', 'Condition', 'Interoperable Resource', AppColors.medicalGreen),
          const Divider(height: 20),
          _buildStepRow(context, '5. FHIR Bundle', 'Package', 'Complete Clinical Package', AppColors.darkSlate),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context,
    String title,
    String badge,
    String subtitle,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(badge, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStickyActionBar(BuildContext context, String termCode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: const Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.goNamed(
                    AppRouter.mapping,
                    pathParameters: {'code': termCode},
                  );
                },
                child: const Text('View Mapping'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  context.push('/fhir-bundle/$termCode');
                },
                child: const Text('Generate Bundle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
