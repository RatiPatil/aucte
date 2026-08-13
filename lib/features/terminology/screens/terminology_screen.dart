import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/clinical_term_model.dart';
import '../repositories/firestore_terminology_repository.dart';
import '../repositories/terminology_repository.dart';
import '../widgets/term_card.dart';

class TerminologyScreen extends StatefulWidget {
  const TerminologyScreen({super.key});

  @override
  State<TerminologyScreen> createState() => _TerminologyScreenState();
}

class _TerminologyScreenState extends State<TerminologyScreen> {
  final _searchController = TextEditingController();
  final TerminologyRepository _repo = FirestoreTerminologyRepository.instance;

  List<ClinicalTermModel> _terms = [];
  String _selectedSystem = 'All';
  bool _isLoading = true;

  final List<String> _systems = const ['All', 'Ayurveda', 'Siddha', 'Unani'];

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTerms() async {
    setState(() {
      _isLoading = true;
    });

    List<ClinicalTermModel> list;
    if (_searchController.text.trim().isNotEmpty) {
      list = await _repo.search(_searchController.text);
      if (_selectedSystem != 'All') {
        list = list
            .where(
              (t) => t.system.toLowerCase() == _selectedSystem.toLowerCase(),
            )
            .toList();
      }
    } else if (_selectedSystem != 'All') {
      list = await _repo.filterBySystem(_selectedSystem);
    } else {
      list = await _repo.getAllTerms();
    }

    if (mounted) {
      setState(() {
        _terms = list;
        _isLoading = false;
      });
    }
  }

  void _showTermDetails(ClinicalTermModel term) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      term.system.toUpperCase(),
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
                      color: AppColors.warningSoft,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Demo Dataset',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                term.namasteTerm,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NAMASTE Code: ${term.namasteCode}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(term.description, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 20),
              Text(
                'Dual Coding Mapping Pipeline',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Mapping Pipeline visualization
              _MappingNodeBox(
                title: 'NAMASTE Traditional Concept',
                code: term.namasteCode,
                display: term.namasteTerm,
                badgeColor: AppColors.primary,
              ),
              const Center(
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              _MappingNodeBox(
                title: 'ICD-11 Traditional Medicine Module 2 (TM2)',
                code: term.tm2Code,
                display: term.tm2Title,
                badgeColor: const Color(0xFF16A36A),
              ),
              const Center(
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              _MappingNodeBox(
                title: 'ICD-11 Biomedical Classification',
                code: term.biomedicineCode,
                display: term.biomedicineTitle,
                badgeColor: const Color(0xFF2563EB),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mapping Confidence: ${(term.mappingConfidence * 100).toInt()}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Type: ${term.mappingType}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Close Mapping View'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NAMASTE Terminology Engine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search_rounded),
            tooltip: 'Advanced Search',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.terminologySearch);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _loadTerms(),
                    decoration: InputDecoration(
                      hintText: 'Search terms, codes, TM2, biomedicine...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                _loadTerms();
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _systems.map((sys) {
                        final selected = _selectedSystem == sys;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: selected,
                            label: Text(sys),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.white,
                            checkmarkColor: AppColors.white,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: selected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setState(() {
                                _selectedSystem = sys;
                              });
                              _loadTerms();
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Terms Count banner
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${_terms.length} Terms',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Demo Dataset (100 Records)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Terms List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _terms.isEmpty
                  ? Center(
                      child: Text(
                        'No matching terms found.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _terms.length,
                      itemBuilder: (context, index) {
                        final term = _terms[index];
                        return TermCard(
                          term: term,
                          onTap: () => _showTermDetails(term),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MappingNodeBox extends StatelessWidget {
  const _MappingNodeBox({
    required this.title,
    required this.code,
    required this.display,
    required this.badgeColor,
  });

  final String title;
  final String code;
  final String display;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
        ],
      ),
    );
  }
}
