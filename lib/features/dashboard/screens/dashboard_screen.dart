/// AUCTE — Module 2 Terminology Repository & Clinical Search Workspace.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_medical_card.dart';
import '../../authentication/models/user_model.dart';
import '../../terminology/models/namaste_code_model.dart';
import '../../terminology/providers/terminology_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  String _query = '';
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      if (_searchFocusNode.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final searchResults = _query.isEmpty
        ? <NamasteCodeModel>[]
        : ref.watch(terminologySearchResultsProvider).valueOrNull ?? <NamasteCodeModel>[];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Welcome Header ────────────────────────────────
              _buildWelcomeHeader(context, userAsync),
              const SizedBox(height: 20),

              // ── 2. HERO SEARCH BAR (Always Visible, Animated Focus) ─
              _buildHeroSearchBar(context, isDark, searchResults),
              const SizedBox(height: 20),

              // ── 3. Compact Quick Actions ──────────────────────────
              _buildQuickActionsRow(context, isDark),
              const SizedBox(height: 24),

              // ── 4. Recent Searches Compact List ───────────────────
              _buildRecentSearchesSection(context, isDark),
              const SizedBox(height: 24),

              // ── 5. Trending AYUSH Terminology Small Grid ──────────
              _buildTrendingTerminologyGrid(context, isDark),
              const SizedBox(height: 24),

              // ── 6. Lightweight Module 2 Analytics Charts ───────────
              _buildModule2ChartsSection(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Welcome Header ───────────────────────────────────────────
  Widget _buildWelcomeHeader(BuildContext context, AsyncValue<UserModel?> userAsync) {
    final theme = Theme.of(context);

    return userAsync.when(
      data: (user) {
        final doctorName = user?.displayName ?? 'Dr. Ratikant';
        final hospital = user?.hospital ?? 'All India Institute of Ayurveda';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUCTE',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepPurple,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'FHIR Clinical Terminology Platform',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkSlate,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '👋 Welcome $doctorName • $hospital',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.deepPurple,
              child: Text(
                doctorName.replaceAll('Dr. ', '').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Text('Loading Clinician Context...', style: TextStyle(color: AppColors.textSecondary)),
      error: (_, __) => const Text('AUCTE Clinical Engine', style: TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.bold)),
    );
  }

  // ── 2. HERO SEARCH BAR ──────────────────────────────────────────
  Widget _buildHeroSearchBar(
      BuildContext context, bool isDark, List<dynamic> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isSearchFocused
                  ? AppColors.deepPurple
                  : AppColors.borderLight,
              width: _isSearchFocused ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isSearchFocused
                    ? AppColors.deepPurple.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isSearchFocused ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (val) {
              setState(() => _query = val.trim());
              ref.read(terminologySearchQueryProvider.notifier).state = val.trim();
            },
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                context.go('/terminology');
              }
            },
            decoration: InputDecoration(
              hintText: 'Search disease name or NAMASTE code (e.g., "Jwara", "Kasa", "Suram")...',
              hintStyle: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.deepPurple,
                size: 24,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '⌘K',
                      style: TextStyle(
                        color: AppColors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),

        // Instant Debounced Suggestions Dropdown
        if (_query.isNotEmpty && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: suggestions.take(4).length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final item = suggestions[idx];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.medical_services_outlined, color: AppColors.deepPurple, size: 18),
                  title: Text(
                    '${item.namasteTerm} (${item.namasteCode})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkSlate),
                  ),
                  subtitle: Text(
                    'System: ${item.system} • Category: ${item.category}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textDisabled),
                  onTap: () => context.push('/terminology/${item.namasteCode}'),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ── 3. Compact Quick Actions Bar (Icon Buttons Only) ────────────
  Widget _buildQuickActionsRow(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactActionButton(
          context,
          icon: Icons.search_rounded,
          label: 'Search',
          onTap: () => context.go('/terminology'),
        ),
        _buildCompactActionButton(
          context,
          icon: Icons.grid_view_rounded,
          label: 'Categories',
          onTap: () => context.go('/terminology'),
        ),
        _buildCompactActionButton(
          context,
          icon: Icons.history_rounded,
          label: 'Recent',
          onTap: () => context.go('/terminology'),
        ),
        _buildCompactActionButton(
          context,
          icon: Icons.star_border_rounded,
          label: 'Favorites',
          onTap: () => context.go('/terminology'),
        ),
      ],
    );
  }

  Widget _buildCompactActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.deepPurple, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.darkSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. Recent Searches Compact List ──────────────────────────────
  Widget _buildRecentSearchesSection(BuildContext context, bool isDark) {
    final recentSearches = [
      {'code': 'NA-01-01-001', 'name': 'Jwara (Fever)', 'system': 'Ayurveda'},
      {'code': 'NS-01-01-001', 'name': 'Suram', 'system': 'Siddha'},
      {'code': 'NU-01-01-001', 'name': 'Humma', 'system': 'Unani'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Searches',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: recentSearches.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: AucteMedicalCard(
                onTap: () => context.push('/terminology/${item['code']}'),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 18, color: AppColors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${item['name']} (${item['code']})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['system']!,
                        style: const TextStyle(
                          color: AppColors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textDisabled),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 5. Trending AYUSH Terminology Small Responsive Card Grid ─────
  Widget _buildTrendingTerminologyGrid(BuildContext context, bool isDark) {
    final trendingTerms = [
      {'code': 'NA-01-01-001', 'name': 'Jwara', 'desc': 'Fever', 'system': 'Ayurveda'},
      {'code': 'NS-01-01-001', 'name': 'Suram', 'desc': 'Fever & Chills', 'system': 'Siddha'},
      {'code': 'NU-01-01-001', 'name': 'Humma', 'desc': 'Pyrexia', 'system': 'Unani'},
      {'code': 'NA-01-02-003', 'name': 'Kasa', 'desc': 'Cough & Bronchitis', 'system': 'Ayurveda'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending AYUSH Terminology',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 80,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: trendingTerms.length,
          itemBuilder: (ctx, idx) {
            final t = trendingTerms[idx];
            return AucteMedicalCard(
              onTap: () => context.push('/terminology/${t['code']}'),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_hospital_rounded, size: 16, color: AppColors.deepPurple),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkSlate),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${t['system']} • ${t['desc']}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── 6. Lightweight Native Flutter Analytics Charts ────────────────
  Widget _buildModule2ChartsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Module 2 Clinical Search Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Donut Chart: Searches by AYUSH System
            Expanded(
              child: AucteMedicalCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Text(
                      'Searches by AYUSH System',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.darkSlate),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: CustomPaint(
                        painter: _DonutChartPainter(),
                        child: const Center(
                          child: Text('85\nTerms', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.deepPurple)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Ayurveda 60% • Siddha 20% • Unani 20%', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Horizontal Bar Chart & Sparkline
            Expanded(
              child: AucteMedicalCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Searched Diseases',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.darkSlate),
                    ),
                    const SizedBox(height: 8),
                    _buildBarRow('Jwara', 0.9, AppColors.deepPurple),
                    _buildBarRow('Suram', 0.65, AppColors.warning),
                    _buildBarRow('Kasa', 0.5, AppColors.medicalGreen),
                    const SizedBox(height: 12),
                    const Text('Weekly Search Activity Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 24,
                      width: double.infinity,
                      child: CustomPaint(painter: _SparklinePainter()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarRow(String label, double pct, Color col) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 42, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.darkSlate))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                color: col,
                backgroundColor: col.withValues(alpha: 0.15),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lightweight Custom Donut Chart Painter ──────────────────────────
class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    // Segment 1: Ayurveda (60%)
    paint.color = AppColors.deepPurple;
    final sweep1 = 2 * math.pi * 0.60;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep1 - 0.05, false, paint);
    startAngle += sweep1;

    // Segment 2: Siddha (20%)
    paint.color = AppColors.warning;
    final sweep2 = 2 * math.pi * 0.20;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep2 - 0.05, false, paint);
    startAngle += sweep2;

    // Segment 3: Unani (20%)
    paint.color = AppColors.medicalGreen;
    final sweep3 = 2 * math.pi * 0.20;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep3 - 0.05, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Lightweight Custom Sparkline Painter ────────────────────────────
class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width, size.height * 0.1),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final paint = Paint()
      ..color = AppColors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
