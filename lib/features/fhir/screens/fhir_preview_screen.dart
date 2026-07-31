/// AUCTE — FHIR Preview Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/fhir_condition_model.dart';
import '../models/fhir_resource.dart';
import '../providers/fhir_providers.dart';
import '../services/fhir_service.dart';


class FhirPreviewScreen extends ConsumerWidget {
  const FhirPreviewScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(fhirResourceProvider(code));

    return Scaffold(
      appBar: AppBar(
        title: const Text('FHIR Resource Generator'),
      ),
      body: resourceAsync.when(
        data: (resource) {
          if (resource == null) {
            return const Center(child: Text('Unable to generate FHIR resource: Mapping not found.'));
          }
          return _FhirPreviewView(resource: resource);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _FhirPreviewView extends ConsumerWidget {
  const _FhirPreviewView({required this.resource});

  final FhirResource resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validation = ref.watch(fhirValidationProvider(resource));
    final theme = Theme.of(context);
    final jsonString = resource.toPrettyJson();

    // Determine title based on resource type dynamically. 
    // In a full implementation we'd check `resource.runtimeType` or use a method on `FhirResource`.
    final resourceTypeDisplay = resource.toJson()['resourceType'] ?? 'Resource';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FHIR R4 $resourceTypeDisplay',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              _buildValidationBadge(context, validation),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? AppColors.surfaceDark 
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SelectableText(
              jsonString,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: theme.brightness == Brightness.dark 
                    ? Colors.greenAccent.shade100 
                    : Colors.blue.shade900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: jsonString));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('FHIR JSON copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy JSON'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // In a real app this would export to a file,
                    // for now we'll just show a snackbar per requirements to not upload/export externally.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download simulated locally.')),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final namasteCode = (resource is FhirConditionModel)
                    ? (resource as FhirConditionModel).namasteCode
                    : 'NA-01-01-001';
                context.push('/fhir-bundle/$namasteCode');
              },
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Generate FHIR R4 Bundle Package'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationBadge(BuildContext context, FhirValidationResult validation) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;
    String label;

    switch (validation.status) {
      case ValidationStatus.valid:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = 'Valid';
        break;
      case ValidationStatus.warning:
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        label = 'Warning';
        break;
      case ValidationStatus.error:
        color = Colors.red;
        icon = Icons.error_outline_rounded;
        label = 'Error';
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
}
