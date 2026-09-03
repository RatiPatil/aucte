import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../authentication/models/practitioner_model.dart';
import '../../authentication/repositories/firebase_auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PractitionerModel? _practitioner;

  @override
  void initState() {
    super.initState();
    _loadPractitioner();
  }

  void _loadPractitioner() {
    // Always read from FirebaseAuthRepository — it stores the real
    // authenticated session regardless of provider (Google or email).
    final p = FirebaseAuthRepository.instance.getCurrentPractitioner();
    setState(() {
      _practitioner = p;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Sign Out?'),
          content: const Text(
            'Are you sure you want to end your current session?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // FirebaseAuthRepository.logout() signs out of both Firebase
      // and Google Sign-In, then clears the local session.
      await FirebaseAuthRepository.instance.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _practitioner;
    final name = p?.fullName.isNotEmpty == true
        ? p!.fullName
        : 'AYUSH Practitioner';
    final email = p?.email ?? '';
    final mobile = p?.mobile ?? '';
    final practitionerId = p?.practitionerId ?? '';
    final system = p?.ayushSystem ?? 'Ayurveda';
    final institution = p?.institution ?? '';
    final photoURL = p?.photoURL;
    final provider = p?.provider ?? 'email';
    final isGoogleUser = provider == 'google';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Practitioner Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ─── Header Card ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile photo — Google profile image or initials avatar
                    _ProfileAvatar(
                      name: name,
                      photoURL: photoURL,
                      size: 40,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name.toUpperCase(),
                      style: AppTextStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    // Provider badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            '$system Specialist',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isGoogleUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.infoSoft,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user_rounded,
                                  size: 12,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Google Account',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Professional Details ───────────────────────────────────
              _ProfileSectionCard(
                title: 'Professional Information',
                children: [
                  if (practitionerId.isNotEmpty) ...[
                    _ProfileDetailTile(
                      icon: Icons.badge_outlined,
                      label: 'Registration ID',
                      value: practitionerId,
                    ),
                    const Divider(height: 1),
                  ],
                  if (institution.isNotEmpty) ...[
                    _ProfileDetailTile(
                      icon: Icons.account_balance_outlined,
                      label: 'Institution',
                      value: institution,
                    ),
                    const Divider(height: 1),
                  ],
                  _ProfileDetailTile(
                    icon: Icons.spa_outlined,
                    label: 'AYUSH System',
                    value: system,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ─── Contact Details ────────────────────────────────────────
              _ProfileSectionCard(
                title: 'Contact Details',
                children: [
                  if (email.isNotEmpty) ...[
                    _ProfileDetailTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                    ),
                  ],
                  if (mobile.isNotEmpty) ...[
                    const Divider(height: 1),
                    _ProfileDetailTile(
                      icon: Icons.phone_outlined,
                      label: 'Mobile',
                      value: mobile,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // ─── Application Info ───────────────────────────────────────
              _ProfileSectionCard(
                title: 'Application',
                children: const [
                  _ProfileDetailTile(
                    icon: Icons.info_outline,
                    label: 'Version',
                    value: 'AUCTE v1.0.0',
                  ),
                  Divider(height: 1),
                  _ProfileDetailTile(
                    icon: Icons.security_outlined,
                    label: 'Platform',
                    value: 'AYUSH Unified Clinical Terminology Engine',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ─── Logout ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Avatar ──────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    required this.size,
    this.photoURL,
  });

  final String name;
  final String? photoURL;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (photoURL != null && photoURL!.isNotEmpty) {
      return CircleAvatar(
        radius: size,
        backgroundColor: AppColors.primarySoft,
        backgroundImage: NetworkImage(photoURL!),
        onBackgroundImageError: (_, _) {},
        child: null,
      );
    }

    // Fallback: initials avatar
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'AU';

    return CircleAvatar(
      radius: size,
      backgroundColor: AppColors.primarySoft,
      child: Text(
        initials,
        style: AppTextStyles.headingSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.55,
        ),
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ─── Detail Tile ─────────────────────────────────────────────────────────────

class _ProfileDetailTile extends StatelessWidget {
  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
