import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../encounters/models/encounter_model.dart';
import '../../encounters/repositories/local_encounter_repository.dart';
import '../models/patient_model.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, this.patient});

  final PatientModel? patient;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  PatientModel? _patient;
  List<EncounterModel> _patientEncounters = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patient == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is PatientModel) {
        _patient = args;
      } else {
        _patient = widget.patient;
      }
      _loadEncounters();
    }
  }

  Future<void> _loadEncounters() async {
    if (_patient == null) return;
    setState(() {
      _isLoading = true;
    });

    final encounters = await LocalEncounterRepository.instance
        .getEncountersByPatient(_patient!.id);

    if (mounted) {
      setState(() {
        _patientEncounters = encounters;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = _patient;

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Details')),
        body: const Center(child: Text('No patient details provided.')),
      );
    }

    final hasAbha =
        patient.abhaNumber != null && patient.abhaNumber!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(patient.fullName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadEncounters,
          color: AppColors.primary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Card Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              patient.fullName.isNotEmpty
                                  ? patient.fullName[0].toUpperCase()
                                  : 'P',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.primary,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.fullName,
                                  style: AppTextStyles.headingSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${patient.gender} • ${patient.age} yrs old',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      hasAbha
                                          ? Icons.verified_user_rounded
                                          : Icons.badge_outlined,
                                      size: 16,
                                      color: hasAbha
                                          ? AppColors.success
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      hasAbha
                                          ? 'ABHA: ${patient.abhaNumber}'
                                          : 'ID: ${patient.id}',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: hasAbha
                                            ? AppColors.success
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Mobile',
                        value: patient.mobile,
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: [
                          patient.address,
                          if (patient.city.isNotEmpty) patient.city,
                          if (patient.taluka != null && patient.taluka!.isNotEmpty) patient.taluka,
                          if (patient.district != null && patient.district!.isNotEmpty) patient.district,
                          patient.state,
                          if (patient.country != null && patient.country!.isNotEmpty) patient.country,
                          if (patient.pincode != null && patient.pincode!.isNotEmpty) '- ${patient.pincode}',
                        ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ').replaceAll(', -', ' -'),
                      ),
                      if (patient.bloodGroup != null) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.bloodtype_outlined,
                          label: 'Blood Group',
                          value: patient.bloodGroup!,
                        ),
                      ],
                      if (patient.diseaseName != null && patient.diseaseName!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.medical_services_outlined,
                          label: 'Disease',
                          value: patient.diseaseName!,
                        ),
                      ],
                      if (patient.aadhaarNumber != null && patient.aadhaarNumber!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.credit_card_outlined,
                          label: 'Aadhaar',
                          value: 'XXXX-XXXX-${patient.aadhaarNumber!.length >= 12 ? patient.aadhaarNumber!.substring(patient.aadhaarNumber!.length - 4) : 'XXXX'}',
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons: Encounter + FHIR
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.encounter,
                              arguments: patient,
                            );
                            _loadEncounters();
                          },
                          icon: const Icon(Icons.note_add_rounded, size: 18),
                          label: const Text('Start Encounter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.fhirPreview,
                              arguments: {
                                'patient': patient,
                                'title': 'FHIR Patient: ${patient.fullName}',
                              },
                            );
                          },
                          icon: const Icon(Icons.data_object_rounded, size: 18),
                          label: const Text('FHIR JSON'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Encounter History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Encounter History',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
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
                        '${_patientEncounters.length} FHIR Records',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _patientEncounters.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.article_outlined,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No Encounters Recorded Yet',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start a clinical encounter to map dual terminology & create FHIR R4 records.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _patientEncounters.length,
                        itemBuilder: (context, index) {
                          final enc = _patientEncounters[index];
                          final dateStr =
                              "${enc.encounterDate.day}/${enc.encounterDate.month}/${enc.encounterDate.year}";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Encounter: ${enc.id}',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
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
                                const SizedBox(height: 8),
                                Text(
                                  'Chief Complaint: ${enc.chiefComplaint}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Diagnoses: ${enc.diagnoses.map((d) => d.namasteTerm).join(', ')}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.fhirPreview,
                                          arguments: {
                                            'encounter': enc,
                                            'patient': patient,
                                            'title':
                                                'FHIR Encounter: ${patient.fullName}',
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 16,
                                      ),
                                      label: const Text('View FHIR Bundle'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
