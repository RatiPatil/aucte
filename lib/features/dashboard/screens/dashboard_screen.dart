import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/aucte_logo.dart';
import '../../authentication/models/practitioner_model.dart';
import '../../authentication/repositories/firebase_auth_repository.dart';
import '../../encounters/repositories/local_encounter_repository.dart';
import '../../fhir_records/repositories/local_fhir_record_repository.dart';
import '../../patients/repositories/local_patient_repository.dart';
import '../../terminology/repositories/local_terminology_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onNavigateTab});

  final void Function(int index)? onNavigateTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PractitionerModel? _currentPractitioner;
  int _patientCount = 0;
  int _encounterCount = 0;
  int _termCount = 100;
  int _fhirBundleCount = 0;
  bool _isLoading = true;
  bool _isFirebaseConnected = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final practitioner = FirebaseAuthRepository.instance.getCurrentPractitioner();
    final patients = await LocalPatientRepository.instance.getPatients();
    final encounters = await LocalEncounterRepository.instance.getEncounters();
    final terms = await LocalTerminologyRepository.instance.getAllTerms();
    final bundles = await LocalFhirRecordRepository.instance.getBundles();

    // Determine Firebase connectivity by checking if Firebase Auth has an active user
    // A non-null FirebaseAuth currentUser indicates Firebase is reachable.
    bool firebaseConnected = false;
    try {
      final firebaseUser = FirebaseAuthRepository.instance.isLoggedIn;
      firebaseConnected = firebaseUser;
    } catch (_) {
      firebaseConnected = false;
    }

    if (mounted) {
      setState(() {
        _currentPractitioner = practitioner;
        _patientCount = patients.length;
        _encounterCount = encounters.length;
        _termCount = terms.isEmpty ? 100 : terms.length;
        _fhirBundleCount = bundles.length;
        _isLoading = false;
        _isFirebaseConnected = firebaseConnected &&
            (practitioner?.provider == 'google' ||
                practitioner?.provider == 'email');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _currentPractitioner?.fullName.isNotEmpty == true
        ? _currentPractitioner!.fullName
        : 'AYUSH Practitioner';
    final system = _currentPractitioner?.ayushSystem ?? 'Ayurveda';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Row(
                  children: [
                    const AucteLogo(size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Namaste, $name',
                            style: AppTextStyles.headingSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$system Specialist • AUCTE',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No new clinical notifications.'),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(4); // Profile tab
                        } else {
                          Navigator.pushNamed(context, AppRoutes.profile);
                        }
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primarySoft,
                        child: Text(
                          name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
                              : 'D',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF8A33),
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryShadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'DUAL CODING ENGINE',
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unified Clinical Terminology',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'NAMASTE • ICD-11 TM2 • Biomedicine',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(2); // Terminology tab
                          } else {
                            Navigator.pushNamed(context, AppRoutes.terminology);
                          }
                        },
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Search Terminology'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Statistics Section
                Text(
                  'Clinical Metrics',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.people_outline_rounded,
                                  title: 'Patients',
                                  value: '$_patientCount',
                                  subtitle: 'Active roster',
                                  color: const Color(0xFFFF6B00),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.assignment_outlined,
                                  title: 'Encounters',
                                  value: '$_encounterCount',
                                  subtitle: 'Clinical visits',
                                  color: const Color(0xFF16A36A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.data_object_rounded,
                                  title: 'FHIR Bundles',
                                  value: '$_fhirBundleCount',
                                  subtitle: 'R4 Document exports',
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.menu_book_outlined,
                                  title: 'Dual Terms',
                                  value: '$_termCount',
                                  subtitle: 'NAMASTE + TM2',
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                const SizedBox(height: 24),

                // 4. Quick Actions Grid
                Text(
                  'Clinical Quick Actions',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: [
                    _QuickActionTile(
                      icon: Icons.person_add_outlined,
                      label: 'New Patient',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.addPatient);
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.note_add_outlined,
                      label: 'New Encounter',
                      color: const Color(0xFF16A36A),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.encounter);
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.travel_explore_rounded,
                      label: 'Term Search',
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(2);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.terminology);
                        }
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.hub_outlined,
                      label: 'Dual Coding',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.mapping);
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.data_object_rounded,
                      label: 'FHIR Records',
                      color: const Color(0xFF059669),
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(3);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.fhirRecords);
                        }
                      },
                    ),
                    _QuickActionTile(
                      icon: Icons.security_rounded,
                      label: 'Consent',
                      color: const Color(0xFFD97706),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.consent);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 5. System Status Card
                Text(
                  'Engine System Status',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const _StatusRow(
                        title: 'NAMASTE Dataset',
                        statusText: '100 Demo Terms Ready',
                        isGreen: true,
                      ),
                      const Divider(height: 18),
                      const _StatusRow(
                        title: 'WHO ICD-11 TM2',
                        statusText: 'Mapped (Demo Version 2.0)',
                        isGreen: true,
                      ),
                      const Divider(height: 18),
                      const _StatusRow(
                        title: 'FHIR R4 Generator',
                        statusText: 'Enabled (Bundle Builder)',
                        isGreen: true,
                      ),
                      const Divider(height: 18),
                      _StatusRow(
                        title: 'Firebase Integration',
                        statusText: _isFirebaseConnected
                            ? 'Connected'
                            : 'Offline — Local Mode Active',
                        isGreen: _isFirebaseConnected,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.title,
    required this.statusText,
    required this.isGreen,
  });

  final String title;
  final String statusText;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGreen ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: AppTextStyles.bodySmall.copyWith(
                color: isGreen ? AppColors.success : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
