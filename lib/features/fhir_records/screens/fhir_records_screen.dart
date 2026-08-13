import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../encounters/models/encounter_model.dart';
import '../../encounters/repositories/local_encounter_repository.dart';
import '../../patients/repositories/local_patient_repository.dart';

class FhirRecordsScreen extends StatefulWidget {
  const FhirRecordsScreen({super.key});

  @override
  State<FhirRecordsScreen> createState() => _FhirRecordsScreenState();
}

class _FhirRecordsScreenState extends State<FhirRecordsScreen> {
  final _encRepo = LocalEncounterRepository.instance;
  final _patientRepo = LocalPatientRepository.instance;

  List<EncounterModel> _encounters = [];
  Map<String, String> _patientNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFhirRecords();
  }

  Future<void> _loadFhirRecords() async {
    setState(() {
      _isLoading = true;
    });

    final encs = await _encRepo.getEncounters();
    final patients = await _patientRepo.getPatients();

    final names = <String, String>{};
    for (final p in patients) {
      names[p.id] = p.fullName;
    }

    if (mounted) {
      setState(() {
        _encounters = encs;
        _patientNames = names;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('FHIR R4 Records Repository')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFhirRecords,
          color: AppColors.primary,
          child: Column(
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                color: AppColors.primarySoft,
                child: Row(
                  children: [
                    const Icon(
                      Icons.data_object_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Interoperable FHIR R4 Bundle documents containing dual-coded diagnoses and patient consent metadata.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _encounters.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_off_outlined,
                                size: 64,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No FHIR Bundles Generated Yet',
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Complete a clinical encounter to automatically generate FHIR R4 documents.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _encounters.length,
                        itemBuilder: (context, index) {
                          final enc = _encounters[index];
                          final patientName =
                              _patientNames[enc.patientId] ??
                              'Patient ${enc.patientId}';
                          final dateStr =
                              "${enc.encounterDate.day}/${enc.encounterDate.month}/${enc.encounterDate.year}";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySoft,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'FHIR Bundle',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      dateStr,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Patient: $patientName',
                                  style: AppTextStyles.headingSmall.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Chief Complaint: ${enc.chiefComplaint}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Diagnoses: ${enc.diagnoses.map((d) => "${d.namasteTerm} (${d.namasteCode})").join(', ')}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.fhirPreview,
                                          arguments: {'encounter': enc},
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.code_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('View FHIR JSON'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
