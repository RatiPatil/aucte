import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/clinical_term_model.dart';
import '../repositories/local_terminology_repository.dart';
import '../repositories/terminology_repository.dart';

/// The primary SIH terminology search screen.
/// Searches NAMASTE terms/codes, filters by AYUSH system,
/// shows autocomplete suggestions, and displays dual coding pipeline
/// (NAMASTE → ICD-11 TM2 + ICD-11 Biomedicine).
class TerminologySearchScreen extends StatefulWidget {
  const TerminologySearchScreen({super.key});

  @override
  State<TerminologySearchScreen> createState() =>
      _TerminologySearchScreenState();
}

class _TerminologySearchScreenState extends State<TerminologySearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final TerminologyRepository _repo = LocalTerminologyRepository.instance;

  List<ClinicalTermModel> _allTerms = [];
  List<ClinicalTermModel> _filteredTerms = [];
  List<String> _suggestions = [];
  String _selectedSystem = 'All';
  bool _isLoading = true;
  bool _showSuggestions = false;
  ClinicalTermModel? _selectedTerm;

  late final AnimationController _cardAnimController;
  late final Animation<double> _cardFadeAnim;

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
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cardFadeAnim = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    );
    _loadAll();

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final terms = await _repo.getAllTerms();
    if (mounted) {
      setState(() {
        _allTerms = terms;
        _filteredTerms = terms;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    final filtered = _allTerms.where((t) {
      final sysMatch =
          _selectedSystem == 'All' ||
          t.system.toLowerCase() == _selectedSystem.toLowerCase();
      if (!sysMatch) return false;
      return t.namasteTerm.toLowerCase().contains(q) ||
          t.namasteCode.toLowerCase().contains(q) ||
          t.whoTerm.toLowerCase().contains(q) ||
          t.tm2Code.toLowerCase().contains(q) ||
          t.biomedicineCode.toLowerCase().contains(q) ||
          t.tm2Title.toLowerCase().contains(q) ||
          t.biomedicineTitle.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q);
    }).toList();

    // Build autocomplete suggestions from namaste terms
    final suggestions = filtered.map((t) => t.namasteTerm).take(6).toList();

    setState(() {
      _filteredTerms = filtered;
      _suggestions = suggestions;
      _showSuggestions = q.isNotEmpty && suggestions.isNotEmpty;
      _selectedTerm = null;
    });
  }

  void _onSystemSelected(String system) {
    setState(() => _selectedSystem = system);
    _onSearchChanged(_searchController.text);
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchFocusNode.unfocus();
    setState(() => _showSuggestions = false);
    _onSearchChanged(suggestion);
  }

  void _selectTerm(ClinicalTermModel term) {
    setState(() {
      _selectedTerm = term;
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();
    _cardAnimController
      ..reset()
      ..forward();
  }

  void _clearSelection() {
    setState(() {
      _selectedTerm = null;
      _searchController.clear();
      _filteredTerms = _allTerms
          .where(
            (t) =>
                _selectedSystem == 'All' ||
                t.system.toLowerCase() == _selectedSystem.toLowerCase(),
          )
          .toList();
    });
  }

  Color _systemColor(String system) {
    switch (system) {
      case 'Ayurveda':
        return const Color(0xFFFF6B00);
      case 'Siddha':
        return const Color(0xFF7C3AED);
      case 'Unani':
        return const Color(0xFF0284C7);
      case 'Homeopathy':
        return const Color(0xFF059669);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NAMASTE Terminology Search'),
        actions: [
          if (_selectedTerm != null)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Clear selection',
              onPressed: _clearSelection,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_selectedTerm != null)
              Expanded(child: _buildDualCodingView(_selectedTerm!))
            else
              Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field with autocomplete
          Stack(
            children: [
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search NAMASTE term, code, TM2, biomedicine...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Autocomplete dropdown
          if (_showSuggestions) ...[
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _suggestions.map((s) {
                  return InkWell(
                    onTap: () => _selectSuggestion(s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(s, style: AppTextStyles.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // System filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _systems.map((sys) {
                final isSelected = _selectedSystem == sys;
                final color = _systemColor(sys);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sys),
                    selected: isSelected,
                    selectedColor: color,
                    backgroundColor: AppColors.surfaceSoft,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    onSelected: (_) => _onSystemSelected(sys),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Results count bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '${_filteredTerms.length} terms',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
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
                  Flexible(
                    child: Text(
                      'Demo Dataset (${_allTerms.length} records)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_filteredTerms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text('No matching terms found', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Try a different keyword or system filter',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _filteredTerms.length,
      itemBuilder: (context, index) {
        final term = _filteredTerms[index];
        final color = _systemColor(term.system);
        return _TermResultTile(
          term: term,
          accentColor: color,
          onTap: () => _selectTerm(term),
        );
      },
    );
  }

  Widget _buildDualCodingView(ClinicalTermModel term) {
    final systemColor = _systemColor(term.system);
    return FadeTransition(
      opacity: _cardFadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _SystemBadge(system: term.system, color: systemColor),
                const SizedBox(width: 8),
                if (term.isDemo)
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

            const SizedBox(height: 12),

            Text(
              term.namasteTerm,
              style: AppTextStyles.headingLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NAMASTE Code: ${term.namasteCode}',
              style: AppTextStyles.labelMedium.copyWith(
                color: systemColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(term.description, style: AppTextStyles.bodyMedium),
            if (term.whoTerm.isNotEmpty)
              Text(
                'WHO Ayurveda term (sample): ${term.whoTerm}',
                style: AppTextStyles.bodySmall,
              ),

            const SizedBox(height: 28),

            // Dual Coding Pipeline title
            Row(
              children: [
                const Icon(
                  Icons.account_tree_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text('Dual Coding Pipeline', style: AppTextStyles.headingSmall),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              'Traditional Diagnosis → NAMASTE → ICD-11 TM2 + ICD-11 Biomedicine → FHIR Condition',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            // ── NAMASTE node ──
            _PipelineNode(
              tier: 'NAMASTE Traditional Concept',
              code: term.namasteCode,
              title: term.namasteTerm,
              color: systemColor,
              icon: Icons.spa_rounded,
            ),

            _PipelineConnector(),

            // ── Branch row: TM2 + Biomedicine ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PipelineNode(
                    tier: 'ICD-11 TM2',
                    code: term.tm2Code,
                    title: term.tm2Title,
                    color: const Color(0xFF16A36A),
                    icon: Icons.local_hospital_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PipelineNode(
                    tier: 'ICD-11 Biomedicine',
                    code: term.biomedicineCode,
                    title: term.biomedicineTitle,
                    color: const Color(0xFF2563EB),
                    icon: Icons.biotech_rounded,
                  ),
                ),
              ],
            ),

            _PipelineConnector(),

            // ── FHIR Condition node ──
            _PipelineNode(
              tier: 'FHIR R4 Condition Resource',
              code: 'Condition.code',
              title:
                  'Dual coded: ${term.tm2Code} (TM2) + ${term.biomedicineCode} (Biomedicine)',
              color: const Color(0xFF7C3AED),
              icon: Icons.local_fire_department_rounded,
            ),

            const SizedBox(height: 28),

            // Mapping metadata
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _MetaRow(
                    label: 'Mapping Type',
                    value: term.mappingType.toUpperCase(),
                  ),
                  const Divider(height: 16),
                  _MetaRow(
                    label: 'Confidence',
                    value: term.isDemo
                        ? 'Synthetic'
                        : '${(term.mappingConfidence * 100).toInt()}%',
                    valueColor: term.mappingConfidence >= 0.9
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  const Divider(height: 16),
                  _MetaRow(label: 'Source', value: term.source),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.fhirPreview,
                        arguments: {
                          'term': term,
                          'title': 'FHIR Condition: ${term.namasteTerm}',
                        },
                      );
                    },
                    icon: const Icon(Icons.code_rounded, size: 18),
                    label: const Text('View FHIR Condition JSON'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearSelection,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back to Search Results'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _TermResultTile extends StatelessWidget {
  const _TermResultTile({
    required this.term,
    required this.accentColor,
    required this.onTap,
  });

  final ClinicalTermModel term;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SystemBadge(system: term.system, color: accentColor),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    term.namasteCode,
                    style: AppTextStyles.caption.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              term.namasteTerm,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              term.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                _CodePill(
                  label: 'TM2',
                  code: term.tm2Code,
                  color: const Color(0xFF16A36A),
                ),
                _CodePill(
                  label: 'Bio',
                  code: term.biomedicineCode,
                  color: const Color(0xFF2563EB),
                ),
                Text(
                  term.isDemo
                      ? 'Synthetic mapping'
                      : '${(term.mappingConfidence * 100).toInt()}% confidence',
                  style: AppTextStyles.caption.copyWith(
                    color: term.mappingConfidence >= 0.9
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemBadge extends StatelessWidget {
  const _SystemBadge({required this.system, required this.color});

  final String system;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        system.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CodePill extends StatelessWidget {
  const _CodePill({
    required this.label,
    required this.code,
    required this.color,
  });

  final String label;
  final String code;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: code),
          ],
        ),
        style: AppTextStyles.caption.copyWith(color: color),
      ),
    );
  }
}

class _PipelineNode extends StatelessWidget {
  const _PipelineNode({
    required this.tier,
    required this.code,
    required this.title,
    required this.color,
    required this.icon,
  });

  final String tier;
  final String code;
  final String title;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  tier,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 2,
              height: 12,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            Icon(
              Icons.arrow_downward_rounded,
              color: AppColors.primary.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodySmall.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
