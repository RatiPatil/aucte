/// AUCTE — FHIR R4 Bundle Preview Screen.
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_medical_card.dart';
import '../../../shared/widgets/aucte_section_header.dart';
import '../models/fhir_bundle_model.dart';
import '../providers/fhir_bundle_providers.dart';
import '../widgets/emr_integration_dialog.dart';
import '../services/fhir_service.dart';

class FhirBundlePreviewScreen extends ConsumerWidget {
  const FhirBundlePreviewScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundleAsync = ref.watch(bundleProvider(code));

    return Scaffold(
      appBar: AppBar(
        title: const Text('FHIR R4 Bundle Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Regenerate Bundle',
            onPressed: () {
              ref
                  .read(bundleRegenerateTokenProvider(code).notifier)
                  .update((state) => state + 1);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Regenerating FHIR Bundle...')),
              );
            },
          ),
        ],
      ),
      body: bundleAsync.when(
        data: (bundle) {
          if (bundle == null) {
            return const Center(
              child: Text('Unable to generate FHIR Bundle: Mapping not found.'),
            );
          }
          return _FhirBundleView(code: code, bundle: bundle);
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.lg),
              Text('Assembling FHIR R4 Bundle Package...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Error generating FHIR Bundle: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class _FhirBundleView extends ConsumerStatefulWidget {
  const _FhirBundleView({
    required this.code,
    required this.bundle,
  });

  final String code;
  final FhirBundleModel bundle;

  @override
  ConsumerState<_FhirBundleView> createState() => _FhirBundleViewState();
}

class _FhirBundleViewState extends ConsumerState<_FhirBundleView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final validation = ref.watch(bundleValidationProvider(widget.bundle));
    final isPretty = ref.watch(bundleExportPrettyProvider);

    final jsonText = isPretty
        ? widget.bundle.toPrettyJson()
        : jsonEncode(widget.bundle.toJson());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Validation Status ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FHIR R4 Bundle Package',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Type: ${widget.bundle.type} • ${widget.bundle.total} Linked Resources',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              _buildValidationBadge(context, validation),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Metadata Summary Card ──────────────────────────────
          AucteMedicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryTeal, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Bundle Metadata & Identifiers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.lg),
                _buildMetaRow(context, 'Bundle ID', widget.bundle.id),
                _buildMetaRow(context, 'FHIR Version', widget.bundle.metadata.fhirVersion),
                _buildMetaRow(context, 'Bundle Type', widget.bundle.type),
                _buildMetaRow(
                  context,
                  'Timestamp',
                  widget.bundle.metadata.timestamp.toIso8601String(),
                ),
                _buildMetaRow(context, 'Generator', widget.bundle.metadata.generator),
                _buildMetaRow(
                  context,
                  'Identifier',
                  widget.bundle.metadata.identifier,
                  isMonospace: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Resource Entries Section ──────────────────────────
          const AucteSectionHeader(title: 'Included FHIR Resources'),
          const SizedBox(height: AppSpacing.xs),

          ...widget.bundle.entries.map((entry) {
            final json = entry.resource.toJson();
            final resourceType = json['resourceType'] as String? ?? 'Resource';
            final id = json['id'] as String? ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xxs,
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  side: const BorderSide(color: AppColors.primaryTeal),
                ),
                backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                collapsedBackgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getResourceIcon(resourceType),
                    color: AppColors.primaryTeal,
                    size: 20,
                  ),
                ),
                title: Text(
                  '$resourceType/$id',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'FullURL: ${entry.fullUrl}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    color: isDark ? Colors.black26 : Colors.grey.shade50,
                    child: SelectableText(
                      entry.resource.toPrettyJson(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: isDark
                            ? Colors.greenAccent.shade100
                            : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),

          // ── Full Bundle JSON Viewer & Live Search ──────────────
          const AucteSectionHeader(title: 'Interactive Bundle JSON Viewer'),
          const SizedBox(height: AppSpacing.sm),

          // Search Bar & Format Controls
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search JSON (e.g. "Condition", "NA-01")...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ChoiceChip(
                label: Text(isPretty ? 'Pretty' : 'Raw'),
                selected: isPretty,
                onSelected: (selected) {
                  ref.read(bundleExportPrettyProvider.notifier).state = selected;
                },
                selectedColor: AppColors.primaryTeal.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // JSON Monospace Viewer
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                jsonText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: _searchQuery.isNotEmpty &&
                          jsonText.toLowerCase().contains(_searchQuery.toLowerCase())
                      ? Colors.amberAccent
                      : Colors.greenAccent.shade100,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Action Buttons ────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                EmrIntegrationDialog.show(context, widget.bundle);
              },
              icon: const Icon(Icons.cloud_upload_rounded),
              label: const Text('Send / Simulate EMR Upload (Module 8)'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final repo = ref.read(fhirBundleRepositoryProvider);
                    await repo.copyBundle(widget.bundle, pretty: isPretty);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('FHIR R4 Bundle copied to clipboard.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy Bundle JSON'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Bundle (${widget.bundle.id.substring(0, 8)}...) exported locally.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Bundle'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Regenerate / Revalidate Action Row
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    final val = ref.read(bundleValidationProvider(widget.bundle));
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('FHIR Bundle Validation'),
                        content: Text(val.message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Re-validate Bundle'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    ref
                        .read(bundleRegenerateTokenProvider(widget.code).notifier)
                        .update((state) => state + 1);
                  },
                  icon: const Icon(Icons.autorenew_rounded),
                  label: const Text('Regenerate UUIDs'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context,
    String label,
    String value, {
    bool isMonospace = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: isMonospace ? 'monospace' : null,
                fontSize: isMonospace ? 12 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationBadge(
    BuildContext context,
    FhirValidationResult validation,
  ) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;
    String label;

    switch (validation.status) {
      case ValidationStatus.valid:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = 'Valid R4 Bundle';
        break;
      case ValidationStatus.warning:
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        label = 'Warning';
        break;
      case ValidationStatus.error:
        color = Colors.red;
        icon = Icons.error_outline_rounded;
        label = 'Validation Error';
        break;
    }

    return Tooltip(
      message: validation.message,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'Patient':
        return Icons.person_outline;
      case 'Practitioner':
        return Icons.badge_outlined;
      case 'Encounter':
        return Icons.local_hospital_outlined;
      case 'Condition':
        return Icons.medical_information_outlined;
      default:
        return Icons.data_object_outlined;
    }
  }
}
