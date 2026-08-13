import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/aucte_logo.dart';
import '../repositories/firebase_auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _practitionerIdController = TextEditingController();
  final _institutionController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authRepo = FirebaseAuthRepository.instance;

  String _selectedAyushSystem = 'Ayurveda';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _ayushSystems = const [
    'Ayurveda',
    'Siddha',
    'Unani',
    'Homeopathy',
    'Sowa-Rigpa',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _practitionerIdController.dispose();
    _institutionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.register(
        fullName: _fullNameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        practitionerId: _practitionerIdController.text,
        ayushSystem: _selectedAyushSystem,
        institution: _institutionController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please sign in.'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Practitioner Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AucteLogo(size: 56)),
                const SizedBox(height: 12),
                Text(
                  'Join AUCTE Network',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Register your clinical identity for terminology integration',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Dr. Ramesh Sharma',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter full name' : null,
                ),
                const SizedBox(height: 14),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'doctor@hospital.org',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter valid email'
                      : null,
                ),
                const SizedBox(height: 14),

                // Mobile
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: '9876543210',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v == null || v.trim().length < 10
                      ? 'Enter 10-digit mobile number'
                      : null,
                ),
                const SizedBox(height: 14),

                // Practitioner ID
                TextFormField(
                  controller: _practitionerIdController,
                  decoration: const InputDecoration(
                    labelText: 'AYUSH Practitioner Registration ID',
                    hintText: 'e.g. AYU-REG-2026-089',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter Practitioner Registration ID'
                      : null,
                ),
                const SizedBox(height: 14),

                // AYUSH System Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedAyushSystem,
                  decoration: const InputDecoration(
                    labelText: 'AYUSH Specialization System',
                    prefixIcon: Icon(Icons.spa_outlined),
                  ),
                  items: _ayushSystems.map((system) {
                    return DropdownMenuItem(value: system, child: Text(system));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedAyushSystem = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Institution
                TextFormField(
                  controller: _institutionController,
                  decoration: const InputDecoration(
                    labelText: 'Clinical Institution / Hospital',
                    hintText: 'All India Institute of Ayurveda',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter institution name'
                      : null,
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Account Password',
                    hintText: 'Min. 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Register Practitioner Account',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
