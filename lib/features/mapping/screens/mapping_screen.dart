/// AUCTE — Concept Mapping Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/mapping_providers.dart';
import '../models/mapping_result.dart';

class MappingScreen extends ConsumerStatefulWidget {
  const MappingScreen({super.key, required this.code});

  final String code;

  @override
  ConsumerState<MappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends ConsumerState<MappingScreen> {
  @override
  void initState() {
    super.initState();
    // Seed dummy data if needed (for demonstration only)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mappingRepositoryProvider).seedDummyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mappingAsync = ref.watch(mappingResultProvider(widget.code));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ConceptMap Viewer (NAMASTE → TM2 → ICD-11)'),
      ),
      body: mappingAsync.when(
        data: (result) {
          if (result == null) {
            return _buildNotFound(theme);
          }
          return _buildMappingView(context, result);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Error loading mapping:\n$e',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_off_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No mapping available',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This terminology has not been mapped to TM2 or ICD-11 yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingView(BuildContext context, MappingResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMappingMetadata(context, result),
          const SizedBox(height: AppSpacing.xxl),
          
          // NAMASTE Card
          _buildSystemCard(
            context,
            system: 'NAMASTE',
            code: result.namaste.code,
            title: result.namaste.name,
            subtitle: result.namaste.category,
            icon: Icons.qr_code_2_rounded,
            color: AppColors.primaryTeal,
          ),
          
          _buildConnector(context),
          
          // TM2 Card
          _buildSystemCard(
            context,
            system: 'WHO TM2',
            code: result.tm2?.code ?? 'N/A',
            title: result.tm2?.title ?? 'Not Mapped',
            subtitle: result.tm2?.category ?? '',
            icon: Icons.public_rounded,
            color: Colors.blueAccent,
          ),
          
          _buildConnector(context),
          
          // ICD-11 Card
          _buildSystemCard(
            context,
            system: 'ICD-11',
            code: result.icd11?.code ?? 'N/A',
            title: result.icd11?.title ?? 'Not Mapped',
            subtitle: result.icd11?.chapter ?? '',
            icon: Icons.medical_services_outlined,
            color: Colors.purpleAccent,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.goNamed(
                      AppRouter.fhirPreview,
                      pathParameters: {'code': result.namaste.code},
                    );
                  },
                  icon: const Icon(Icons.code_rounded),
                  label: const Text('FHIR Condition'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.push('/fhir-bundle/${result.namaste.code}');
                  },
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('FHIR Bundle'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMappingMetadata(BuildContext context, MappingResult result) {
    final theme = Theme.of(context);
    final map = result.conceptMap;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMetaItem(context, 'Type', map.mappingType, Icons.merge_type_rounded),
          _buildMetaItem(context, 'Confidence', map.confidence, Icons.verified_user_outlined),
        ],
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            )),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemCard(
    BuildContext context, {
    required String system,
    required String code,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      system,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        code,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(BuildContext context) {
    return Container(
      height: 40,
      width: 2,
      color: Theme.of(context).colorScheme.outlineVariant,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
