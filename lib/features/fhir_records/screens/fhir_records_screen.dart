import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/fhir_bundle_model.dart';
import '../repositories/local_fhir_record_repository.dart';

class FhirRecordsScreen extends StatefulWidget {
  const FhirRecordsScreen({super.key});

  @override
  State<FhirRecordsScreen> createState() => _FhirRecordsScreenState();
}

class _FhirRecordsScreenState extends State<FhirRecordsScreen> {
  final _fhirRepo = LocalFhirRecordRepository.instance;

  List<FhirBundleModel> _allBundles = [];
  List<FhirBundleModel> _filteredBundles = [];
  String _searchQuery = '';
  String _selectedSystem = 'All';
  bool _isLoading = true;

  static const List<String> _systems = [
    'All',
    'Ayurveda',
    'Siddha',
    'Unani',
    'Homeopathy',
  ];

  @override
  void initState() {
    super.initState();
    _loadFhirRecords();
  }

  Future<void> _loadFhirRecords() async {
    setState(() {
      _isLoading = true;
    });

    final bundles = await _fhirRepo.getBundles();

    if (mounted) {
      setState(() {
        _allBundles = bundles;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    final q = _searchQuery.trim().toLowerCase();
    final filtered = _allBundles.where((b) {
      // System match
      final systemMatch = _selectedSystem == 'All' ||
          b.practitioner.ayushSystem.toLowerCase() ==
              _selectedSystem.toLowerCase() ||
          b.conditions.any((c) =>
              c.term.system.toLowerCase() == _selectedSystem.toLowerCase());

      if (!systemMatch) return false;

      // Query match
      if (q.isEmpty) return true;

      final patMatch = b.patient.name.toLowerCase().contains(q) ||
          b.patient.id.toLowerCase().contains(q);
      final diagMatch = b.conditions.any((c) =>
          c.term.namasteTerm.toLowerCase().contains(q) ||
          c.term.namasteCode.toLowerCase().contains(q) ||
          c.term.tm2Code.toLowerCase().contains(q) ||
          c.term.biomedicineCode.toLowerCase().contains(q));
      final complaintMatch =
          b.encounter.reasonCodes.any((r) => r.toLowerCase().contains(q));

      return patMatch || diagMatch || complaintMatch;
    }).toList();

    setState(() {
      _filteredBundles = filtered;
    });
  }

  void _copyBundleJson(FhirBundleModel bundle) {
    Clipboard.setData(ClipboardData(text: bundle.toFormattedJson()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('FHIR Bundle ${bundle.id} copied to clipboard!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FHIR R4 Records Repository'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFhirRecords,
          color: AppColors.primary,
          child: Column(
            children: [
              // Search & Filter Header
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search patient, diagnosis, NAMASTE / TM2...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSoft,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _systems.map((sys) {
                          final isSelected = _selectedSystem == sys;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(sys),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceSoft,
                              labelStyle: AppTextStyles.caption.copyWith(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                              onSelected: (_) {
                                setState(() => _selectedSystem = sys);
                                _applyFilters();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Metrics Counter Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primarySoft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredBundles.length} Bundles Available',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ABDM R4 Profile Verified',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                    : _filteredBundles.isEmpty
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
                                    'No FHIR Bundles Found',
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
                            itemCount: _filteredBundles.length,
                            itemBuilder: (context, index) {
                              final bundle = _filteredBundles[index];
                              final dateStr =
                                  "${bundle.timestamp.day}/${bundle.timestamp.month}/${bundle.timestamp.year}";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
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
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'FHIR R4 Bundle',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          dateStr,
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Patient: ${bundle.patient.name}',
                                      style: AppTextStyles.headingSmall.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (bundle.patient.abhaNumber != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'ABHA: ${bundle.patient.abhaNumber}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(
                                      'Complaints: ${bundle.encounter.reasonCodes.join(", ")}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Dual Diagnoses Pills
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: bundle.conditions.map((c) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceSoft,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          child: Text(
                                            '${c.term.namasteTerm} (${c.term.tm2Code})',
                                            style: AppTextStyles.caption.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy_rounded,
                                            size: 18,
                                            color: AppColors.textSecondary,
                                          ),
                                          tooltip: 'Copy FHIR JSON',
                                          onPressed: () =>
                                              _copyBundleJson(bundle),
                                        ),
                                        const SizedBox(width: 4),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.fhirPreview,
                                              arguments: {
                                                'bundle': bundle,
                                                'title':
                                                    'FHIR Document: ${bundle.patient.name}',
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 16,
                                          ),
                                          label: const Text('View FHIR Bundle'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(
                                              color: AppColors.primary,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.encounter);
          _loadFhirRecords();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New FHIR Record',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
