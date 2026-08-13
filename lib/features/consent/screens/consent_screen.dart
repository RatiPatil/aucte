import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _consentClinicalDoc = true;
  bool _consentTerminology = true;
  bool _consentFhir = true;
  bool _consentDemoData = true;

  bool _isGranted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Consent Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Consent Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _isGranted
                      ? AppColors.successSoft
                      : AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isGranted
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isGranted
                          ? Icons.verified_user_rounded
                          : Icons.gpp_bad_rounded,
                      color: _isGranted ? AppColors.success : AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isGranted ? 'Consent Granted' : 'Consent Declined',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: _isGranted
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isGranted
                                ? 'Active for clinical documentation & FHIR R4 export'
                                : 'Records will not be processed into FHIR bundles',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _isGranted
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Purpose of Clinical Consent',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AUCTE requires explicit consent to parse traditional medicine diagnoses, map them to ICD-11 TM2 and biomedical standards, and construct structured FHIR R4 clinical bundles.',
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 24),

              Text(
                'Granular Permissions',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _consentClinicalDoc,
                      activeColor: AppColors.primary,
                      title: const Text('Clinical Documentation'),
                      subtitle: const Text(
                        'Store chief complaints, notes and practitioner observations.',
                      ),
                      onChanged: (val) {
                        setState(() {
                          _consentClinicalDoc = val ?? true;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      value: _consentTerminology,
                      activeColor: AppColors.primary,
                      title: const Text('Terminology Mapping'),
                      subtitle: const Text(
                        'Map NAMASTE codes to WHO ICD-11 TM2 & biomedicine.',
                      ),
                      onChanged: (val) {
                        setState(() {
                          _consentTerminology = val ?? true;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      value: _consentFhir,
                      activeColor: AppColors.primary,
                      title: const Text('FHIR Record Generation'),
                      subtitle: const Text(
                        'Generate structured FHIR R4 Bundle JSON documents.',
                      ),
                      onChanged: (val) {
                        setState(() {
                          _consentFhir = val ?? true;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      value: _consentDemoData,
                      activeColor: AppColors.primary,
                      title: const Text('Demo Data Processing'),
                      subtitle: const Text(
                        'Allow processing in AUCTE prototype demonstration dataset.',
                      ),
                      onChanged: (val) {
                        setState(() {
                          _consentDemoData = val ?? true;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Disclaimer: This prototype demonstrates consent metadata inspired by ABDM principles. It is not an official ABDM production consent manager.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isGranted = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Consent granted successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Grant Consent'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isGranted = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Consent declined.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
