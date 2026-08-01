/// AUCTE — Spotlight Terminology Search & System Filter Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_medical_card.dart';
import '../../../shared/widgets/aucte_section_header.dart';
import '../models/namaste_code_model.dart';
import '../providers/terminology_providers.dart';

class TerminologySearchScreen extends ConsumerStatefulWidget {
  const TerminologySearchScreen({super.key});

  @override
  ConsumerState<TerminologySearchScreen> createState() => _TerminologySearchScreenState();
}

class _TerminologySearchScreenState extends ConsumerState<TerminologySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selectedSystem = 'All Systems';
  String _selectedCategory = 'All Categories';

  final List<String> _systems = const [
    'All Systems',
    'Ayurveda',
    'Siddha',
    'Unani',
    'Homeopathy',
    'Yoga & Naturopathy',
  ];

  final List<String> _categories = const [
    'All Categories',
    'Kaya Chikitsa',
    'Pranavaha Srotas',
    'Annavaha Srotas',
    'Shalya Tantra',
    'Kaumarbhritya',
    'Body System',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(terminologySearchQueryProvider);
    final searchResultsAsync = ref.watch(terminologySearchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final popularTermsAsync = ref.watch(popularTerminologyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search NAMASTE Terminology'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          110,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Spotlight Search Input Bar ─────────────────────────
            _buildSpotlightInputBar(context, searchQuery),
            const SizedBox(height: 12),

            // ── 2. AYUSH System Filter Chips ──────────────────────────
            _buildSystemFilterChips(),
            const SizedBox(height: 8),

            // ── 3. Category & Body System Filter Chips ────────────────
            _buildCategoryFilterChips(),
            const SizedBox(height: AppSpacing.lg),

            // ── 4. Results Feed OR Suggestion Dashboard ──────────────
            if (searchQuery.isNotEmpty)
              searchResultsAsync.when(
                data: (results) {
                  final filtered = results.where((term) {
                    final matchesSystem = _selectedSystem == 'All Systems' ||
                        term.system.toLowerCase() == _selectedSystem.toLowerCase();
                    final matchesCategory = _selectedCategory == 'All Categories' ||
                        term.category.toLowerCase().contains(_selectedCategory.toLowerCase());
                    return matchesSystem && matchesCategory;
                  }).toList();

                  return _buildSearchResultsList(context, searchQuery, filtered);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text('Search error: $e', style: const TextStyle(color: AppColors.medicalRed)),
                  ),
                ),
              )
            else ...[
              // Recent Searches
              if (recentSearches.isNotEmpty) _buildRecentSearchesChips(context, recentSearches),
              const SizedBox(height: AppSpacing.xl),

              // Popular Terms
              const AucteSectionHeader(title: 'Popular AYUSH Conditions'),
              const SizedBox(height: AppSpacing.xs),
              popularTermsAsync.when(
                data: (popular) => _buildPopularTermsList(context, popular),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading popular: $e'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlightInputBar(BuildContext context, String currentQuery) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus ? AppColors.deepPurple : AppColors.borderLight,
          width: _focusNode.hasFocus ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        autofocus: false,
        onChanged: (val) {
          ref.read(terminologySearchQueryProvider.notifier).state = val;
        },
        decoration: InputDecoration(
          hintText: 'Search disease name or NAMASTE code...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.deepPurple),
          suffixIcon: currentQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(terminologySearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSystemFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _systems.map((sys) {
          final isSelected = _selectedSystem == sys;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(sys),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedSystem = sys);
              },
              selectedColor: AppColors.deepPurple.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.deepPurple : AppColors.darkSlate,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.deepPurple : AppColors.borderLight,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = cat);
              },
              selectedColor: AppColors.warning.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.warning : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.warning : AppColors.borderLight,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResultsList(
    BuildContext context,
    String query,
    List<NamasteCodeModel> results,
  ) {
    final theme = Theme.of(context);

    if (results.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 44, color: AppColors.textDisabled),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No clinical terms found matching "$query"',
              style: theme.textTheme.titleSmall?.copyWith(color: AppColors.darkSlate),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Try adjusting your system filter or search query.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AucteSectionHeader(title: 'Matching Results (${results.length})'),
        const SizedBox(height: AppSpacing.xs),
        ...results.map((term) => _buildResultItem(context, query, term)),
      ],
    );
  }

  Widget _buildResultItem(
    BuildContext context,
    String query,
    NamasteCodeModel term,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AucteMedicalCard(
        onTap: () {
          ref.read(recentSearchesProvider.notifier).addRecentSearch(term);
          context.push('/terminology/${term.code}');
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_outlined, color: AppColors.deepPurple, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${term.name} (${term.code})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkSlate),
                  ),
                  Text(
                    'System: ${term.system} • Category: ${term.category}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchesChips(
    BuildContext context,
    List<NamasteCodeModel> recent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AucteSectionHeader(title: 'Recent Searches'),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          children: recent.map((item) {
            return ActionChip(
              avatar: const Icon(Icons.history_rounded, size: 14, color: AppColors.deepPurple),
              label: Text('${item.name} (${item.code})'),
              onPressed: () => context.push('/terminology/${item.code}'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularTermsList(
    BuildContext context,
    List<NamasteCodeModel> popular,
  ) {
    return Column(
      children: popular.map((term) => _buildResultItem(context, '', term)).toList(),
    );
  }
}
