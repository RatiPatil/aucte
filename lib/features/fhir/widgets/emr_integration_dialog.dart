/// AUCTE — Module 8 EMR Integration Simulator.
///
/// Simulates FHIR R4 Bundle validation, HTTP POST payload transmission to EMR,
/// HTTP 200 OK Response payload rendering, and audit log persistence.
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fhir_bundle_model.dart';

class EmrIntegrationDialog extends StatefulWidget {
  const EmrIntegrationDialog({super.key, required this.bundle});

  final FhirBundleModel bundle;

  static Future<void> show(BuildContext context, FhirBundleModel bundle) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EmrIntegrationDialog(bundle: bundle),
    );
  }

  @override
  State<EmrIntegrationDialog> createState() => _EmrIntegrationDialogState();
}

class _EmrIntegrationDialogState extends State<EmrIntegrationDialog> {
  int _currentStep = 0; // 0: Validate, 1: Transmit, 2: Response
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  Future<void> _runSimulation() async {
    // Step 1: Validate Bundle
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _currentStep = 1);

    // Step 2: Transmit HTTP POST to EMR API
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _currentStep = 2;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mockResponse = {
      'resourceType': 'OperationOutcome',
      'id': 'emr-tx-${DateTime.now().millisecondsSinceEpoch}',
      'status': '200 OK',
      'issue': [
        {
          'severity': 'information',
          'code': 'informational',
          'diagnostics': 'FHIR R4 Bundle successfully received and ingested by Hospital EMR API.',
        }
      ],
      'auditLog': {
        'transactionId': 'TX-${widget.bundle.id}',
        'endpoint': 'https://emr.abdm.gov.in/api/v1/fhir/Bundle',
        'timestamp': DateTime.now().toIso8601String(),
        'resourcesIngested': widget.bundle.entries.length,
      }
    };

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.cloud_upload_rounded, color: AppColors.darkOrange),
          const SizedBox(width: 10),
          Text(
            'EMR Integration Simulator (Module 8)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Endpoint: https://emr.abdm.gov.in/api/v1/fhir/Bundle',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),

            // Stepper Status
            _buildStepStatusItem('1. FHIR R4 Bundle Validation', _currentStep >= 0, _currentStep == 0),
            _buildStepStatusItem('2. HTTP POST Transmission (ABDM Gateway)', _currentStep >= 1, _currentStep == 1),
            _buildStepStatusItem('3. EMR Ingestion & Audit Log Save', _currentStep >= 2, false),
            const SizedBox(height: 16),

            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.medicalGreen),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: AppColors.medicalGreen, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'HTTP 200 OK — Bundle Ingested Successfully',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.medicalGreen, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      const JsonEncoder.withIndent('  ').convert(mockResponse),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isProcessing)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close & Complete'),
          ),
      ],
    );
  }

  Widget _buildStepStatusItem(String label, bool isDone, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isDone
                ? (isCurrent ? Icons.sync : Icons.check_circle)
                : Icons.radio_button_unchecked,
            color: isDone
                ? (isCurrent ? AppColors.darkOrange : AppColors.medicalGreen)
                : AppColors.textDisabled,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              color: isDone ? AppColors.darkSlate : AppColors.textDisabled,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
