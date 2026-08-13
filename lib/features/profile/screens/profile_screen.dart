import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../authentication/models/practitioner_model.dart';
import '../../authentication/repositories/local_auth_repository.dart';

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
    final p = LocalAuthRepository.instance.getCurrentPractitioner();
    setState(() {
      _practitioner = p;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out Practitioner?'),
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
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await LocalAuthRepository.instance.logout();
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
    final name = p?.fullName ?? 'Dr. AYUSH Practitioner';
    final email = p?.email ?? 'practitioner@ayush.gov.in';
    final mobile = p?.mobile ?? '9876543210';
    final practitionerId = p?.practitionerId ?? 'AYU-1001';
    final system = p?.ayushSystem ?? 'Ayurveda';
    final institution = p?.institution ?? 'All India Institute of Ayurveda';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Practitioner Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
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
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'D',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: AppTextStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Details Section
              _ProfileSectionCard(
                title: 'Professional Metadata',
                children: [
                  _ProfileDetailTile(
                    icon: Icons.badge_outlined,
                    label: 'Practitioner Reg ID',
                    value: practitionerId,
                  ),
                  const Divider(height: 1),
                  _ProfileDetailTile(
                    icon: Icons.account_balance_outlined,
                    label: 'Institution',
                    value: institution,
                  ),
                  const Divider(height: 1),
                  _ProfileDetailTile(
                    icon: Icons.spa_outlined,
                    label: 'AYUSH System',
                    value: system,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _ProfileSectionCard(
                title: 'Account Contact Details',
                children: [
                  _ProfileDetailTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email,
                  ),
                  const Divider(height: 1),
                  _ProfileDetailTile(
                    icon: Icons.phone_outlined,
                    label: 'Mobile',
                    value: mobile,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _ProfileSectionCard(
                title: 'Prototype Information',
                children: [
                  const _ProfileDetailTile(
                    icon: Icons.info_outline,
                    label: 'Version',
                    value: 'AUCTE v1.0.0 (SIH Prototype)',
                  ),
                  const Divider(height: 1),
                  const _ProfileDetailTile(
                    icon: Icons.verified_user_outlined,
                    label: 'Status',
                    value: 'Local Demo Dataset Connected',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  label: const Text('Sign Out Practitioner Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

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
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
