/// AUCTE — Official Government Doctor & Admin Authentication Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/user_role.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.doctor;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _applyDemoCredentials(UserRole role) {
    setState(() {
      _selectedRole = role;
      _errorMessage = null;
      switch (role) {
        case UserRole.doctor:
          _emailController.text = 'dr.sharma@aiia.gov.in';
          _passwordController.text = 'AyushDoc#2026';
          break;
        case UserRole.terminologyAdmin:
          _emailController.text = 'admin.namaste@ayush.gov.in';
          _passwordController.text = 'AyushAdmin#2026';
          break;
        case UserRole.systemAdmin:
          _emailController.text = 'sysadmin.abdm@gov.in';
          _passwordController.text = 'SysAdmin#2026';
          break;
        default:
          _emailController.text = 'clinician@ayush.gov.in';
          _passwordController.text = 'AyushPass#2026';
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate authenticating and logging user into state
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    try {
      final email = _emailController.text.trim();
      final doctorName = email.contains('sharma')
          ? 'Dr. Rajesh Sharma'
          : (email.contains('admin') ? 'Admin Terminology Specialist' : 'AYUSH Clinician');

      ref.read(userRepositoryProvider).setMockUser(
            email: email,
            displayName: doctorName,
            role: _selectedRole,
            hospital: 'All India Institute of Ayurveda',
            department: 'Ayurveda Clinical Terminology Wing',
          );

      context.go(AppRouter.dashboardPath);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Authentication failed. Please check your credentials.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header Branding ──────────────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.deepPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: AppColors.deepPurple,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AUCTE Portal',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkSlate,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'Ayush Unified Clinical Terminology Engine',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Government Compliance Subtitle ──────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.deepPurple.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified_user_rounded, color: AppColors.deepPurple, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ministry of Ayush • ABDM Integrated Clinical Gateway',
                              style: TextStyle(
                                color: AppColors.deepPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Role Selection Chips ────────────────────────
                    Text(
                      'Select Access Role',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildRoleChip(UserRole.doctor, 'Government Doctor'),
                        _buildRoleChip(UserRole.terminologyAdmin, 'Terminology Admin'),
                        _buildRoleChip(UserRole.systemAdmin, 'System Admin'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Error Banner ────────────────────────────────
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.medicalRed),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.medicalRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.medicalRed, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Email Input ─────────────────────────────────
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Government Email / Professional ID',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'dr.sharma@aiia.gov.in',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your professional email address.';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Password Input ──────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Login Button ────────────────────────────────
                    FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Authenticate & Access Engine'),
                    ),
                    const SizedBox(height: 20),

                    // ── Demo Quick Fill Section for Judges ──────────
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Judge Evaluation Quick-Fill Credentials:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickFillButton(
                          'Doctor',
                          () => _applyDemoCredentials(UserRole.doctor),
                        ),
                        _buildQuickFillButton(
                          'Term Admin',
                          () => _applyDemoCredentials(UserRole.terminologyAdmin),
                        ),
                        _buildQuickFillButton(
                          'Sys Admin',
                          () => _applyDemoCredentials(UserRole.systemAdmin),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Access Request Link ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New AYUSH Clinician? ',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => context.push('/request-access'),
                          child: const Text(
                            'Request ABDM Credentials',
                            style: TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role, String label) {
    final isSelected = _selectedRole == role;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedRole = role);
      },
      selectedColor: AppColors.deepPurple.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepPurple : AppColors.darkSlate,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.deepPurple : AppColors.borderLight,
      ),
    );
  }

  Widget _buildQuickFillButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.deepPurple),
      ),
    );
  }
}
