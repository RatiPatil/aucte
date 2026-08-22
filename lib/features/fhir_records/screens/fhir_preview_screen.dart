import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../authentication/models/practitioner_model.dart';
import '../../authentication/repositories/local_auth_repository.dart';
import '../../consent/models/consent_model.dart';
import '../../encounters/models/encounter_model.dart';
import '../../patients/models/patient_model.dart';
import '../../patients/repositories/local_patient_repository.dart';
import '../../terminology/models/clinical_term_model.dart';
import '../models/fhir_models.dart';
import '../repositories/local_fhir_record_repository.dart';
import '../services/fhir_builder_service.dart';

class FhirPreviewScreen extends StatefulWidget {
  const FhirPreviewScreen({
    super.key,
    this.bundle,
    this.encounter,
    this.term,
    this.patient,
    this.fhirJson,
    this.title,
  });

  final FhirBundleModel? bundle;
  final EncounterModel? encounter;
  final ClinicalTermModel? term;
  final PatientModel? patient;
  final String? fhirJson;
  final String? title;

  @override
  State<FhirPreviewScreen> createState() => _FhirPreviewScreenState();
}

class _FhirPreviewScreenState extends State<FhirPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  FhirBundleModel? _bundle;
  FhirConditionModel? _singleCondition;
  String _jsonContent = '';
  String _screenTitle = 'FHIR R4 Preview';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _resolveArguments();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _resolveArguments() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    FhirBundleModel? bundle = widget.bundle;
    EncounterModel? encounter = widget.encounter;
    ClinicalTermModel? term = widget.term;
    PatientModel? patient = widget.patient;
    String? fhirJson = widget.fhirJson;
    String? title = widget.title;

    if (args is Map<String, dynamic>) {
      if (args.containsKey('bundle') && args['bundle'] is FhirBundleModel) {
        bundle = args['bundle'] as FhirBundleModel;
      }
      if (args.containsKey('encounter') && args['encounter'] is EncounterModel) {
        encounter = args['encounter'] as EncounterModel;
      }
      if (args.containsKey('term') && args['term'] is ClinicalTermModel) {
        term = args['term'] as ClinicalTermModel;
      }
      if (args.containsKey('patient') && args['patient'] is PatientModel) {
        patient = args['patient'] as PatientModel;
      }
      if (args.containsKey('fhirJson') && args['fhirJson'] is String) {
        fhirJson = args['fhirJson'] as String;
      }
      if (args.containsKey('title') && args['title'] is String) {
        title = args['title'] as String;
      }
    } else if (args is FhirBundleModel) {
      bundle = args;
    } else if (args is EncounterModel) {
      encounter = args;
    } else if (args is ClinicalTermModel) {
      term = args;
    } else if (args is PatientModel) {
      patient = args;
    }

    if (bundle != null) {
      _bundle = bundle;
      _jsonContent = bundle.toFormattedJson();
      _screenTitle = title ?? 'FHIR Document Bundle';
    } else if (encounter != null) {
      // Find or build bundle for encounter
      final existing = await LocalFhirRecordRepository.instance
          .getBundleByEncounter(encounter.id);
      if (existing != null) {
        _bundle = existing;
        _jsonContent = existing.toFormattedJson();
      } else {
        final pat = patient ??
            await LocalPatientRepository.instance
                .getPatientById(encounter.patientId) ??
            PatientModel(
              id: encounter.patientId,
              fullName: 'Patient ${encounter.patientId}',
              gender: 'other',
              dateOfBirth: DateTime(1990, 1, 1),
              mobile: '',
              address: 'Clinical Center',
              city: 'New Delhi',
              state: 'Delhi',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
        final pract = LocalAuthRepository.instance.getCurrentPractitioner() ??
            PractitionerModel(
              id: encounter.practitionerId,
              fullName: 'Dr. AYUSH Specialist',
              email: 'doctor@ayush.gov.in',
              mobile: '9876543210',
              practitionerId: 'AYU-1001',
              ayushSystem: 'Ayurveda',
              institution: 'All India Institute of Ayurveda',
              password: '',
              createdAt: DateTime(2026, 1, 1),
            );
        final consent = encounter.consentId != null
            ? ConsentModel(
                id: encounter.consentId!,
                patientId: pat.id,
                encounterId: encounter.id,
                practitionerId: pract.id,
                purpose:
                    'Clinical documentation, dual coding & FHIR record generation',
                status: 'granted',
                grantedAt: encounter.encounterDate,
                version: '1.0',
                createdAt: encounter.createdAt,
              )
            : null;

        final newBundle = FHIRBuilderService.buildTypedBundle(
          patient: pat,
          practitioner: pract,
          encounter: encounter,
          consent: consent,
        );
        _bundle = newBundle;
        _jsonContent = newBundle.toFormattedJson();
      }
      _screenTitle = title ?? 'Encounter FHIR Bundle';
    } else if (term != null) {
      final cond = FhirConditionModel.fromClinicalTerm(term);
      _singleCondition = cond;
      _jsonContent = cond.toJsonString();
      _screenTitle = title ?? 'FHIR Condition: ${term.namasteTerm}';
    } else if (patient != null) {
      _jsonContent = FHIRBuilderService.buildPatientJson(patient);
      _screenTitle = title ?? 'FHIR Patient: ${patient.fullName}';
    } else if (fhirJson != null && fhirJson.isNotEmpty) {
      _jsonContent = fhirJson;
      try {
        final map = jsonDecode(fhirJson) as Map<String, dynamic>;
        if (map['resourceType'] == 'Bundle') {
          _bundle = FhirBundleModel.fromFhirMap(map);
        } else if (map['resourceType'] == 'Condition') {
          _singleCondition = FhirConditionModel.fromFhirMap(map);
        }
      } catch (_) {}
      _screenTitle = title ?? 'FHIR Resource Preview';
    } else {
      _jsonContent = '''{
  "resourceType": "Bundle",
  "id": "auc-bundle-demo",
  "type": "document",
  "meta": {
    "profile": ["https://aucte.ayush.gov.in/fhir/StructureDefinition/aucte-clinical-document"]
  },
  "entry": []
}''';
      _screenTitle = title ?? 'FHIR R4 Bundle';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _jsonContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('FHIR R4 Resource JSON copied to clipboard!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy FHIR JSON',
            onPressed: _copyToClipboard,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_customize_outlined, size: 20),
              text: 'Visual Breakdown',
            ),
            Tab(
              icon: Icon(Icons.code_rounded, size: 20),
              text: 'FHIR JSON',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Visual Breakdown
                  _buildVisualBreakdown(),

                  // Tab 2: Raw FHIR JSON Syntax Viewer
                  _buildRawJsonViewer(),
                ],
              ),
      ),
    );
  }

  Widget _buildVisualBreakdown() {
    if (_bundle != null) {
      return _buildBundleVisuals(_bundle!);
    } else if (_singleCondition != null) {
      return _buildConditionVisuals(_singleCondition!);
    } else {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.data_object_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Standalone FHIR R4 Resource',
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Switch to the "FHIR JSON" tab to view the complete standard specification.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBundleVisuals(FhirBundleModel bundle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bundle Meta Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2D3E), Color(0xFF1E1E2C)],
              ),
              borderRadius: BorderRadius.circular(20),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FHIR R4 DOCUMENT BUNDLE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${bundle.totalResources} Resources',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Bundle ID: ${bundle.id}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Profile: ${bundle.profileUrl}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Generated: ${bundle.timestamp.day}/${bundle.timestamp.month}/${bundle.timestamp.year} at ${bundle.timestamp.hour}:${bundle.timestamp.minute.toString().padLeft(2, '0')}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Dual Coded Conditions Section
          Row(
            children: [
              const Icon(
                Icons.account_tree_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dual-Coded Diagnoses (Conditions)',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...bundle.conditions.map((c) => _buildConditionCard(c)),

          const SizedBox(height: 20),

          // 3. Patient Resource Card
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Patient Resource',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPatientCard(bundle.patient),

          const SizedBox(height: 20),

          // 4. Practitioner Resource Card
          Row(
            children: [
              const Icon(
                Icons.medical_services_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Practitioner Resource',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPractitionerCard(bundle.practitioner),

          const SizedBox(height: 20),

          // 5. Encounter Resource Card
          Row(
            children: [
              const Icon(
                Icons.event_note_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Encounter Resource',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildEncounterCard(bundle.encounter),

          // 6. Consent Resource if present
          if (bundle.consent != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Consent Resource (ABDM Policy)',
                  style: AppTextStyles.headingSmall.copyWith(fontSize: 17),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildConsentCard(bundle.consent!),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildConditionVisuals(FhirConditionModel condition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConditionCard(condition),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is a single FHIR Condition resource featuring AUCTE dual coding (NAMASTE + ICD-11 TM2 + ICD-11 Biomedicine).',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard(FhirConditionModel cond) {
    final term = cond.term;
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  '${term.system} Concept',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Status: ${cond.clinicalStatus}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            term.namasteTerm,
            style: AppTextStyles.headingSmall.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 4),
          Text(
            'Code ID: ${cond.id}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Triple Coding Pills
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildCodingRow(
                  system: 'NAMASTE System',
                  code: term.namasteCode,
                  display: term.namasteTerm,
                  color: AppColors.primary,
                ),
                const Divider(height: 16),
                _buildCodingRow(
                  system: 'ICD-11 TM2',
                  code: term.tm2Code,
                  display: term.tm2Title,
                  color: const Color(0xFF16A36A),
                ),
                const Divider(height: 16),
                _buildCodingRow(
                  system: 'ICD-11 Biomedicine',
                  code: term.biomedicineCode,
                  display: term.biomedicineTitle,
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodingRow({
    required String system,
    required String code,
    required String display,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                system,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$code: $display',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(FhirPatientModel patient) {
    return Container(
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
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${patient.gender} • DOB: ${patient.birthDate.toIso8601String().split('T')[0]}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (patient.abhaNumber != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ABHA: ${patient.abhaNumber}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPractitionerCard(FhirPractitionerModel pract) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pract.name,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${pract.qualification} — ${pract.institution}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterCard(FhirEncounterModel enc) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class: ${enc.encounterClass.display.toUpperCase()}',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Status: ${enc.status.toUpperCase()}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reason Codes / Complaints:',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            enc.reasonCodes.join(' • '),
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCard(FhirConsentModel consent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Policy: ABDM Patient Privacy',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              Text(
                consent.status.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Purpose: ${consent.purposeText}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRawJsonViewer() {
    return Column(
      children: [
        // Header Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'FHIR R4 JSON',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Standard Interoperable Schema',
                  style: AppTextStyles.labelMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy'),
              ),
            ],
          ),
        ),

        // Dark JSON Syntax Viewer
        Expanded(
          child: Container(
            width: double.infinity,
            color: AppColors.codeBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _jsonContent,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13,
                  color: AppColors.codeText,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.white,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('FHIR R4 Bundle Record verified & active.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
