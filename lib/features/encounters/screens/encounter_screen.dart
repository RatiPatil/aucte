import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../authentication/models/practitioner_model.dart';
import '../../authentication/repositories/local_auth_repository.dart';
import '../../consent/models/consent_model.dart';
import '../../fhir_records/repositories/local_fhir_record_repository.dart';
import '../../fhir_records/services/fhir_builder_service.dart';
import '../../patients/models/patient_model.dart';
import '../../patients/repositories/local_patient_repository.dart';
import '../../terminology/models/clinical_term_model.dart';
import '../../terminology/repositories/local_terminology_repository.dart';
import '../models/encounter_model.dart';
import '../repositories/local_encounter_repository.dart';

class EncounterScreen extends StatefulWidget {
  const EncounterScreen({super.key, this.initialPatient});

  final PatientModel? initialPatient;

  @override
  State<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends State<EncounterScreen> {
  int _currentStep = 0;

  List<PatientModel> _patients = [];
  PatientModel? _selectedPatient;

  final _chiefComplaintController = TextEditingController();
  final _clinicalNotesController = TextEditingController();

  List<ClinicalTermModel> _availableTerms = [];
  final List<ClinicalTermModel> _selectedDiagnoses = [];
  String _termSearchQuery = '';

  bool _consentGranted = true;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patients.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is PatientModel) {
        _selectedPatient = args;
      } else {
        _selectedPatient = widget.initialPatient;
      }
      _loadData();
    }
  }

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _clinicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final patientsList = await LocalPatientRepository.instance.getPatients();
    final termsList = await LocalTerminologyRepository.instance.getAllTerms();

    if (mounted) {
      setState(() {
        _patients = patientsList;
        _availableTerms = termsList;
        if (_selectedPatient == null && patientsList.isNotEmpty) {
          _selectedPatient = patientsList.first;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEncounterAndNavigate() async {
    final patient = _selectedPatient;
    final practitioner = LocalAuthRepository.instance.getCurrentPractitioner();

    if (patient == null || _selectedDiagnoses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a patient and at least one diagnosis.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final encounter = EncounterModel(
      id: '',
      patientId: patient.id,
      practitionerId: practitioner?.id ?? 'DEMO-PRACT-001',
      encounterDate: DateTime.now(),
      chiefComplaint: _chiefComplaintController.text.trim().isNotEmpty
          ? _chiefComplaintController.text.trim()
          : 'General Clinical Evaluation',
      clinicalNotes: _clinicalNotesController.text.trim(),
      diagnoses: _selectedDiagnoses,
      consentId: _consentGranted ? 'CONSENT-GRANTED-DEMO' : null,
      status: 'completed',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final savedEncounter = await LocalEncounterRepository.instance
        .createEncounter(encounter);

    final consent = _consentGranted
        ? ConsentModel(
            id: 'auc-consent-${DateTime.now().millisecondsSinceEpoch}',
            patientId: patient.id,
            encounterId: savedEncounter.id,
            practitionerId: practitioner?.id ?? 'DEMO-PRACT-001',
            purpose:
                'Clinical documentation, dual coding & FHIR record generation',
            status: 'granted',
            grantedAt: DateTime.now(),
            version: '1.0',
            createdAt: DateTime.now(),
          )
        : null;

    final pract = practitioner ??
        PractitionerModel(
          id: 'DEMO-PRACT-001',
          fullName: 'Dr. AYUSH Specialist',
          email: 'doctor@ayush.gov.in',
          mobile: '9876543210',
          practitionerId: 'AYU-1001',
          ayushSystem: 'Ayurveda',
          institution: 'All India Institute of Ayurveda',
          password: '',
          createdAt: DateTime(2026, 1, 1),
        );

    final fhirBundle = FHIRBuilderService.buildTypedBundle(
      patient: patient,
      practitioner: pract,
      encounter: savedEncounter,
      consent: consent,
    );

    // Save FHIR Bundle in local repository
    await LocalFhirRecordRepository.instance.saveBundle(fhirBundle);

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.fhirPreview,
      arguments: {
        'bundle': fhirBundle,
        'encounter': savedEncounter,
        'patient': patient,
        'fhirJson': fhirBundle.toFormattedJson(),
        'title': 'FHIR Bundle: ${patient.fullName}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Clinical Encounter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepTapped: (step) {
                  setState(() {
                    _currentStep = step;
                  });
                },
                onStepContinue: () {
                  if (_currentStep < 4) {
                    setState(() {
                      _currentStep += 1;
                    });
                  } else {
                    _saveEncounterAndNavigate();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              _currentStep == 4
                                  ? 'Generate FHIR Record'
                                  : 'Continue Next Step',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        if (_currentStep > 0) ...[
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Back'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                steps: [
                  // Step 1: Select Patient
                  Step(
                    title: Text(
                      'Select Patient',
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
                    ),
                    subtitle: Text(
                      _selectedPatient?.fullName ??
                          'Choose patient from directory',
                      style: AppTextStyles.bodySmall,
                    ),
                    isActive: _currentStep >= 0,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<PatientModel>(
                          initialValue: _selectedPatient,
                          decoration: const InputDecoration(
                            labelText: 'Patient',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: _patients.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(
                                '${p.fullName} (${p.gender}, ${p.age}y)',
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPatient = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Step 2: Chief Complaint & Notes
                  Step(
                    title: Text(
                      'Chief Complaint & Notes',
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
                    ),
                    subtitle: Text(
                      'Record primary symptoms and findings',
                      style: AppTextStyles.bodySmall,
                    ),
                    isActive: _currentStep >= 1,
                    content: Column(
                      children: [
                        TextFormField(
                          controller: _chiefComplaintController,
                          decoration: const InputDecoration(
                            labelText: 'Chief Complaint *',
                            hintText:
                                'e.g. Dry cough, mild fever and acid reflux for 3 days',
                            prefixIcon: Icon(Icons.sick_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _clinicalNotesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Clinical Examination Notes',
                            hintText:
                                'Pulse, tongue examination, Agni assessment, Pitta elevation',
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step 3: Search & Select NAMASTE Terminology
                  Step(
                    title: Text(
                      'NAMASTE Diagnosis & Dual Coding',
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
                    ),
                    subtitle: Text(
                      '${_selectedDiagnoses.length} Diagnoses Selected',
                      style: AppTextStyles.bodySmall,
                    ),
                    isActive: _currentStep >= 2,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (val) {
                            setState(() {
                              _termSearchQuery = val;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search 100 demo terminology records...',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListView.builder(
                            itemCount: _availableTerms
                                .where(
                                  (t) =>
                                      _termSearchQuery.isEmpty ||
                                      t.namasteTerm.toLowerCase().contains(
                                        _termSearchQuery.toLowerCase(),
                                      ) ||
                                      t.namasteCode.toLowerCase().contains(
                                        _termSearchQuery.toLowerCase(),
                                      ),
                                )
                                .length,
                            itemBuilder: (context, index) {
                              final filtered = _availableTerms
                                  .where(
                                    (t) =>
                                        _termSearchQuery.isEmpty ||
                                        t.namasteTerm.toLowerCase().contains(
                                          _termSearchQuery.toLowerCase(),
                                        ) ||
                                        t.namasteCode.toLowerCase().contains(
                                          _termSearchQuery.toLowerCase(),
                                        ),
                                  )
                                  .toList();
                              final term = filtered[index];
                              final isSelected = _selectedDiagnoses.any(
                                (d) => d.id == term.id,
                              );

                              return CheckboxListTile(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                title: Text(
                                  '${term.namasteTerm} (${term.system})',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'ICD-11 TM2: ${term.tm2Code} • Bio: ${term.biomedicineCode}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedDiagnoses.add(term);
                                    } else {
                                      _selectedDiagnoses.removeWhere(
                                        (d) => d.id == term.id,
                                      );
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step 4: Review Dual Mappings
                  Step(
                    title: Text(
                      'Dual Mapping Review',
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
                    ),
                    subtitle: Text(
                      'Verify NAMASTE -> TM2 -> Biomedicine codes',
                      style: AppTextStyles.bodySmall,
                    ),
                    isActive: _currentStep >= 3,
                    content: Column(
                      children: _selectedDiagnoses.map((d) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${d.namasteTerm} [${d.system}]',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('NAMASTE: ${d.namasteCode}'),
                              Text(
                                'TM2: ${d.tm2Code} — ${d.tm2Title}',
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                'Biomedicine: ${d.biomedicineCode} — ${d.biomedicineTitle}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Step 5: Patient Consent
                  Step(
                    title: Text(
                      'Consent & Generation',
                      style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
                    ),
                    subtitle: Text(
                      'Confirm patient consent for FHIR record export',
                      style: AppTextStyles.bodySmall,
                    ),
                    isActive: _currentStep >= 4,
                    content: Column(
                      children: [
                        CheckboxListTile(
                          value: _consentGranted,
                          activeColor: AppColors.primary,
                          title: const Text('Patient Informed Consent Granted'),
                          subtitle: const Text(
                            'Authorize storing dual-coded terminology & generating FHIR R4 Bundle for interoperable records.',
                          ),
                          onChanged: (val) {
                            setState(() {
                              _consentGranted = val ?? true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
