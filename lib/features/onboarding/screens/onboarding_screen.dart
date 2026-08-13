import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/shared_preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isCompleting = false;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.health_and_safety_rounded,
      badge: 'AYUSH DIGITAL HEALTH',
      title: 'One Clinical Language.\nBetter Connected Care.',
      description:
          'A unified clinical terminology experience designed to help '
          'AYUSH practitioners work with standardized digital health records.',
      features: ['Ayurveda', 'Siddha', 'Unani'],
    ),
    _OnboardingData(
      icon: Icons.hub_rounded,
      badge: 'CLINICAL TERMINOLOGY',
      title: 'Connect NAMASTE\nwith ICD-11.',
      description:
          'Search traditional medicine terminology and explore demo mappings '
          'between NAMASTE, ICD-11 TM2 and biomedical classifications.',
      features: ['NAMASTE', 'ICD-11 TM2', 'Biomedicine'],
    ),
    _OnboardingData(
      icon: Icons.data_object_rounded,
      badge: 'INTEROPERABILITY',
      title: 'Build FHIR-Ready\nClinical Records.',
      description:
          'Create structured records designed around FHIR R4 concepts, '
          'consent-aware workflows and interoperable healthcare data.',
      features: ['FHIR R4', 'Consent', 'Audit Ready'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      await SharedPreferencesService.instance.setBool(
        StorageKeys.onboardingCompleted,
        true,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _completeOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // -------------------------------------------------------------
            // BACKGROUND DECORATION
            // -------------------------------------------------------------
            Positioned(
              top: -110,
              right: -100,
              child: _BackgroundCircle(size: 280, opacity: 0.055),
            ),

            Positioned(
              bottom: -150,
              left: -130,
              child: _BackgroundCircle(size: 330, opacity: 0.035),
            ),

            Column(
              children: [
                // ---------------------------------------------------------
                // TOP BAR
                // ---------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 16, 0),
                  child: Row(
                    children: [
                      const _MiniBrand(),

                      const Spacer(),

                      AnimatedOpacity(
                        opacity: isLastPage ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: IgnorePointer(
                          ignoring: isLastPage,
                          child: TextButton(
                            onPressed: _skip,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: Text(
                              'Skip',
                              style: AppTextStyles.labelMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------------------------------------------------
                // PAGE CONTENT
                // ---------------------------------------------------------
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        pageIndex: index,
                      );
                    },
                  ),
                ),

                // ---------------------------------------------------------
                // BOTTOM SECTION
                // ---------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final selected = index == _currentPage;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: _isCompleting ? null : _nextPage,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isCompleting
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Row(
                                    key: ValueKey(
                                      isLastPage ? 'start' : 'next',
                                    ),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isLastPage ? 'Enter AUCTE' : 'Continue',
                                        style: AppTextStyles.button,
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        isLastPage
                                            ? Icons.health_and_safety_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      Text(
                        'SIH Prototype • Digital Health',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
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

// ============================================================================
// ONBOARDING PAGE
// ============================================================================

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data, required this.pageIndex});

  final _OnboardingData data;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        children: [
          const Spacer(),

          // ----------------------------------------------------------------
          // PREMIUM VISUAL
          // ----------------------------------------------------------------
          TweenAnimationBuilder<double>(
            key: ValueKey(pageIndex),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0.75, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: _ClinicalVisual(icon: data.icon),
          ),

          const SizedBox(height: 38),

          // ----------------------------------------------------------------
          // BADGE
          // ----------------------------------------------------------------
          TweenAnimationBuilder<double>(
            key: ValueKey('badge-$pageIndex'),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                data.badge,
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------------------
          // TITLE
          // ----------------------------------------------------------------
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMedium,
          ),

          const SizedBox(height: 15),

          // ----------------------------------------------------------------
          // DESCRIPTION
          // ----------------------------------------------------------------
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),

          const SizedBox(height: 25),

          // ----------------------------------------------------------------
          // FEATURES
          // ----------------------------------------------------------------
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: data.features
                .map((feature) => _FeatureChip(label: feature))
                .toList(),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

// ============================================================================
// CLINICAL VISUAL
// ============================================================================

class _ClinicalVisual extends StatelessWidget {
  const _ClinicalVisual({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.035),
            ),
          ),

          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.065),
            ),
          ),

          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8A33), AppColors.primary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Icon(icon, size: 58, color: AppColors.white),
          ),

          const Positioned(
            top: 16,
            right: 28,
            child: _FloatingIcon(icon: Icons.add_rounded),
          ),

          const Positioned(
            left: 10,
            bottom: 45,
            child: _FloatingIcon(icon: Icons.favorite_rounded),
          ),

          const Positioned(
            right: 4,
            bottom: 42,
            child: _FloatingIcon(icon: Icons.data_object_rounded),
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Icon(icon, size: 19, color: AppColors.primary),
    );
  }
}

// ============================================================================
// FEATURE CHIP
// ============================================================================

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 7),
          Text(label, style: AppTextStyles.labelMedium.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

// ============================================================================
// TOP BRAND
// ============================================================================

class _MiniBrand extends StatelessWidget {
  const _MiniBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: AppColors.white,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AUCTE',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'DIGITAL HEALTH',
              style: AppTextStyles.overline.copyWith(fontSize: 7),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// BACKGROUND CIRCLE
// ============================================================================

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: opacity),
      ),
    );
  }
}

// ============================================================================
// DATA MODEL
// ============================================================================

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.badge,
    required this.title,
    required this.description,
    required this.features,
  });

  final IconData icon;
  final String badge;
  final String title;
  final String description;
  final List<String> features;
}
