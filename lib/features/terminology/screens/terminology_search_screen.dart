/// AUCTE — Spotlight Terminology Search Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
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
        title: const Text('Search NAMASTE'),
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
            // ── Spotlight Search Input Bar ───────────────────────────
            _buildSpotlightInputBar(context, searchQuery),
            const SizedBox(height: AppSpacing.lg),

            // ── Results Feed OR Suggestion Dashboard ────────────────
            if (searchQuery.isNotEmpty)
              searchResultsAsync.when(
                data: (results) => _buildSearchResultsList(context, searchQuery, results),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text('Search error: $e', style: const TextStyle(color: AppColors.error)),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focusNode.hasFocus ? AppColors.darkOrange : AppColors.borderLight,
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
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.darkOrange),
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
              'Try searching "Jwara", "Kasa", "Prameha", "Siddha", or "Unani".',
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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: AucteMedicalCard(
        onTap: () {
          ref.read(recentSearchesProvider.notifier).addRecentSearch(term);
          context.goNamed(
            AppRouter.terminologyDetail,
            pathParameters: {'code': term.code},
          );
        },
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medical_services_outlined, color: AppColors.darkOrange, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        term.code,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.darkOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.darkSlate.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          term.system,
                          style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    term.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  Text(
                    term.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchesChips(BuildContext context, List<NamasteCodeModel> recent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AucteSectionHeader(title: 'Recent Searches'),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recent.map((term) {
            return ActionChip(
              avatar: const Icon(Icons.history_rounded, size: 14, color: AppColors.darkOrange),
              label: Text('${term.name} (${term.code})'),
              onPressed: () {
                _searchController.text = term.name;
                ref.read(terminologySearchQueryProvider.notifier).state = term.name;
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularTermsList(BuildContext context, List<NamasteCodeModel> popular) {
    return Column(
      children: popular.map((term) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: AucteMedicalCard(
            onTap: () {
              context.goNamed(
                AppRouter.terminologyDetail,
                pathParameters: {'code': term.code},
              );
            },
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      term.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkSlate,
                          ),
                    ),
                    Text(
                      '${term.code} • ${term.system}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDisabled),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
