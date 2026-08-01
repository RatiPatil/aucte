/// AUCTE — Doctor Workspace Dashboard Screen (Reference UI Replica).
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

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Header Bar ─────────────────────────────────
              _buildTopHeaderBar(context, userAsync),
              const SizedBox(height: 20),

              // ── 2. Doctor Greeting ────────────────────────────────
              _buildDoctorGreeting(context, userAsync),
              const SizedBox(height: 18),

              // ── 3. HERO SEARCH BAR ────────────────────────────────
              _buildHeroSearchBar(context, isDark, searchResults),
              const SizedBox(height: 24),

              // ── 4. Quick Actions (5 Cards Row) ───────────────────
              _buildSectionHeader('Quick Actions', null),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 24),

              // ── 5. Continue Working (Horizontal Scroll Cards) ────
              _buildSectionHeader('Continue Working', () => context.go('/terminology')),
              const SizedBox(height: 12),
              _buildContinueWorkingList(context),
              const SizedBox(height: 24),

              // ── 6. Analytics Section (Donut + Top Searched) ──────
              _buildAnalyticsRow(context, isDark),
              const SizedBox(height: 24),

              // ── 7. Today's Activity (4 Statistics Card) ───────────
              _buildTodaysActivityCard(context, isDark),
              const SizedBox(height: 24),

              // ── 8. Recent Activity & 7-Day Search Trend ───────────
              _buildRecentActivityAndTrendRow(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Top Header Bar ─────────────────────────────────────────────
  Widget _buildTopHeaderBar(BuildContext context, AsyncValue<UserModel?> userAsync) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco_rounded, color: AppColors.deepPurple, size: 22),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AUCTE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.deepPurple,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'FHIR Clinical Terminology Platform',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkSlate,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: AppColors.darkSlate, size: 20),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.medicalRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.deepPurple,
              child: const Text(
                'R',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 2. Doctor Greeting ───────────────────────────────────────────
  Widget _buildDoctorGreeting(BuildContext context, AsyncValue<UserModel?> userAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Good Morning, Dr. Ratikant 👋',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkSlate,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Ready to code AYUSH terminology today?',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── 3. HERO SEARCH BAR ──────────────────────────────────────────
  Widget _buildHeroSearchBar(BuildContext context, bool isDark, List<NamasteCodeModel> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isSearchFocused ? AppColors.deepPurple : AppColors.deepPurple.withValues(alpha: 0.4),
              width: _isSearchFocused ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepPurple.withValues(alpha: 0.08),
                blurRadius: 16,
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
              if (val.trim().isNotEmpty) context.go('/terminology');
            },
            decoration: InputDecoration(
              hintText: 'Search NAMASTE, TM2, ICD-11...',
              hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.deepPurple, size: 22),
              suffixIcon: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '⌘ K',
                  style: TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (_query.isNotEmpty && suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
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
                  title: Text('${item.name} (${item.code})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text(item.system, style: const TextStyle(fontSize: 10)),
                  onTap: () => context.push('/terminology/${item.code}'),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ── 4. Quick Actions (5 Cards Grid) ──────────────────────────────
  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.search_rounded, 'label': 'Search\nTerminology', 'bg': const Color(0xFFF3E8FF), 'col': AppColors.deepPurple, 'route': '/terminology'},
      {'icon': Icons.grid_view_rounded, 'label': 'Browse\nCategories', 'bg': const Color(0xFFFFF3DC), 'col': AppColors.warning, 'route': '/terminology'},
      {'icon': Icons.account_tree_rounded, 'label': 'Mapping\nEngine', 'bg': const Color(0xFFF3E8FF), 'col': AppColors.deepPurple, 'route': '/clinical'},
      {'icon': Icons.code_rounded, 'label': 'FHIR\nGenerator', 'bg': const Color(0xFFE6F4EA), 'col': AppColors.medicalGreen, 'route': '/fhir'},
      {'icon': Icons.layers_rounded, 'label': 'Bundle\nGenerator', 'bg': const Color(0xFFE8F0FE), 'col': const Color(0xFF2563EB), 'route': '/fhir'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.map((a) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            width: 86,
            child: AucteMedicalCard(
              onTap: () => context.go(a['route'] as String),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: a['bg'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(a['icon'] as IconData, color: a['col'] as Color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkSlate,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 5. Continue Working Cards ────────────────────────────────────
  Widget _buildContinueWorkingList(BuildContext context) {
    final items = [
      {'title': 'Jwara (Fever)', 'code': 'NA-01-01-001'},
      {'title': 'Kasa (Cough)', 'code': 'NA-02-01-002'},
      {'title': 'Prameha', 'code': 'NA-03-01-003'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            width: 175,
            child: AucteMedicalCard(
              onTap: () => context.push('/terminology/${item['code']}'),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppColors.deepPurple, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.darkSlate),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item['code']!,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textDisabled),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 6. Analytics Section (Donut + Bar Chart) ─────────────────────
  Widget _buildAnalyticsRow(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Donut Chart: Search Distribution
        Expanded(
          child: AucteMedicalCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Search Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.darkSlate)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      height: 74,
                      width: 74,
                      child: CustomPaint(
                        painter: _ReferenceDonutPainter(),
                        child: const Center(
                          child: Text('15%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.darkSlate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendDot(AppColors.deepPurple, 'Ayurveda', '65%'),
                          const SizedBox(height: 4),
                          _buildLegendDot(AppColors.warning, 'Siddha', '20%'),
                          const SizedBox(height: 4),
                          _buildLegendDot(AppColors.medicalGreen, 'Unani', '15%'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Horizontal Bar Chart: Top Searched Diseases
        Expanded(
          child: AucteMedicalCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Searched Diseases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.darkSlate)),
                const SizedBox(height: 8),
                _buildBarItem('Jwara (Fever)', 1.0, 128, AppColors.deepPurple),
                _buildBarItem('Kasa (Cough)', 0.75, 96, AppColors.warning),
                _buildBarItem('Prameha', 0.56, 72, AppColors.medicalGreen),
                _buildBarItem('Arsha (Piles)', 0.37, 48, const Color(0xFF2563EB)),
                _buildBarItem('Vata Vyadhi', 0.28, 36, const Color(0xFFA855F7)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label, String pct) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkSlate, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        Text(pct, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBarItem(String label, double pct, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 9, color: AppColors.darkSlate, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              Text('$count', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.darkSlate)),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. Today's Activity Card ──────────────────────────────────────
  Widget _buildTodaysActivityCard(BuildContext context, bool isDark) {
    return AucteMedicalCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkSlate)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.search_rounded, '24', 'Searches', AppColors.deepPurple, const Color(0xFFF3E8FF)),
              _buildStatItem(Icons.account_tree_rounded, '18', 'Mappings', AppColors.warning, const Color(0xFFFFF3DC)),
              _buildStatItem(Icons.code_rounded, '15', 'FHIR Resources', AppColors.medicalGreen, const Color(0xFFE6F4EA)),
              _buildStatItem(Icons.layers_rounded, '12', 'Bundles', const Color(0xFF2563EB), const Color(0xFFE8F0FE)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String val, String label, Color color, Color bg) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.darkSlate)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── 8. Recent Activity & 7-Day Search Trend Row ─────────────────
  Widget _buildRecentActivityAndTrendRow(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Activity Timeline
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Recent Activity', () => context.go('/terminology')),
              const SizedBox(height: 8),
              _buildTimelineItem(context, '09:15 AM', Icons.search_rounded, 'Searched "Jwara (Fever)"', 'NAMASTE: NA-01-01-001', AppColors.deepPurple),
              _buildTimelineItem(context, '09:20 AM', Icons.account_tree_rounded, 'Mapped to TM2 Code', 'TM2: 120936000', AppColors.warning),
              _buildTimelineItem(context, '09:23 AM', Icons.code_rounded, 'Generated FHIR Condition', 'Condition Resource Created', AppColors.medicalGreen),
              _buildTimelineItem(context, '09:25 AM', Icons.layers_rounded, 'Generated FHIR Bundle', 'Bundle ID: BND-2025-08-01-001', const Color(0xFF2563EB)),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Search Trend (7 Days) Graph Card
        Expanded(
          child: AucteMedicalCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Search Trend (7 Days)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.darkSlate)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: CustomPaint(painter: _SearchTrendSparklinePainter()),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('26 Jul', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                    Text('29 Jul', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                    Text('01 Aug', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, String time, IconData icon, String title, String sub, Color col) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: AucteMedicalCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        onTap: () => context.go('/terminology'),
        child: Row(
          children: [
            Text(time, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Icon(icon, size: 14, color: col),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.darkSlate), overflow: TextOverflow.ellipsis),
                  Text(sub, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkSlate),
        ),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            child: const Text(
              'View all',
              style: TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

// ── Donut Chart Custom Painter ──────────────────────────────────────
class _ReferenceDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 12.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double startAngle = -math.pi / 2;

    // Ayurveda 65%
    paint.color = AppColors.deepPurple;
    final sweep1 = 2 * math.pi * 0.65;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep1 - 0.05, false, paint);
    startAngle += sweep1;

    // Siddha 20%
    paint.color = AppColors.warning;
    final sweep2 = 2 * math.pi * 0.20;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep2 - 0.05, false, paint);
    startAngle += sweep2;

    // Unani 15%
    paint.color = AppColors.medicalGreen;
    final sweep3 = 2 * math.pi * 0.15;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep3 - 0.05, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Search Trend Sparkline Custom Painter ──────────────────────────
class _SearchTrendSparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.65),
      Offset(size.width * 0.16, size.height * 0.50),
      Offset(size.width * 0.33, size.height * 0.60),
      Offset(size.width * 0.50, size.height * 0.15),
      Offset(size.width * 0.66, size.height * 0.45),
      Offset(size.width * 0.83, size.height * 0.75),
      Offset(size.width, size.height * 0.35),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.deepPurple.withValues(alpha: 0.35),
        AppColors.deepPurple.withValues(alpha: 0.02),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    final linePaint = Paint()
      ..color = AppColors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = AppColors.deepPurple;
    final dotWhitePaint = Paint()..color = Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 3.5, dotPaint);
      canvas.drawCircle(p, 1.8, dotWhitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
