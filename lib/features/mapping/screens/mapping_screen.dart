import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../terminology/models/clinical_term_model.dart';
import '../../terminology/repositories/local_terminology_repository.dart';

class MappingScreen extends StatefulWidget {
  const MappingScreen({super.key});

  @override
  State<MappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<MappingScreen> {
  final _repo = LocalTerminologyRepository.instance;

  List<ClinicalTermModel> _allTerms = [];
  ClinicalTermModel? _selectedTerm;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    final terms = await _repo.getAllTerms();
    if (mounted) {
      setState(() {
        _allTerms = terms;
        if (terms.isNotEmpty) {
          _selectedTerm = terms.first;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final term = _selectedTerm;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dual Coding & Terminology Mapping'),
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Clinical Terminology Concept',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Term Selector Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ClinicalTermModel>(
                          isExpanded: true,
                          value: _selectedTerm,
                          items: _allTerms.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(
                                '${t.namasteTerm} [${t.system}] - ${t.namasteCode}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedTerm = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (term != null) ...[
                      // Visual Pipeline Flow
                      Text(
                        'Interoperable Coding Pipeline',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Step 1: Traditional Diagnosis & NAMASTE
                      _PipelineStepCard(
                        stepNumber: '1',
                        title: 'Traditional AYUSH Concept',
                        subtitle: 'NAMASTE Terminology System',
                        code: term.namasteCode,
                        display: term.namasteTerm,
                        systemBadge: term.system,
                        description: term.description,
                        color: AppColors.primary,
                      ),

                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      // Step 2: ICD-11 TM2
                      _PipelineStepCard(
                        stepNumber: '2',
                        title: 'WHO ICD-11 TM2 Classification',
                        subtitle: 'Traditional Medicine Module 2',
                        code: term.tm2Code,
                        display: term.tm2Title,
                        color: const Color(0xFF16A36A),
                      ),

                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      // Step 3: Biomedicine Mapping
                      _PipelineStepCard(
                        stepNumber: '3',
                        title: 'Biomedical Classification',
                        subtitle: 'ICD-11 Biomedical Mapping',
                        code: term.biomedicineCode,
                        display: term.biomedicineTitle,
                        color: const Color(0xFF2563EB),
                      ),

                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      // Step 4: FHIR R4 Bundle Output
                      _PipelineStepCard(
                        stepNumber: '4',
                        title: 'FHIR R4 Condition Resource',
                        subtitle: 'Structured Dual-Coded FHIR Json',
                        code: 'FHIR Condition.code.coding[]',
                        display:
                            'Multi-system dual coding array ready for EHR interchange',
                        color: const Color(0xFF8B5CF6),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.fhirPreview,
                              arguments: {
                                'term': term,
                                'title':
                                    'FHIR R4 Condition: ${term.namasteTerm}',
                              },
                            );
                          },
                          icon: const Icon(Icons.code_rounded, size: 18),
                          label: const Text('Inspect FHIR Condition JSON'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8B5CF6),
                            side: const BorderSide(color: Color(0xFF8B5CF6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CTA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.encounter);
                          },
                          icon: const Icon(Icons.playlist_add_check_rounded),
                          label: const Text(
                            'Add Diagnosis to Clinical Encounter',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _PipelineStepCard extends StatelessWidget {
  const _PipelineStepCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.display,
    this.systemBadge,
    this.description,
    required this.color,
  });

  final String stepNumber;
  final String title;
  final String subtitle;
  final String code;
  final String display;
  final String? systemBadge;
  final String? description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color,
                child: Text(
                  stepNumber,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (systemBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    systemBadge!,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    display,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
