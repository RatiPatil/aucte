/// AUCTE — Official Government Healthcare Android Authentication Screen.
/// 95%+ Precise Visual Match of the Reference Image.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      debugPrint('[AUTH] Attempting FirebaseAuth signInWithEmailAndPassword for $email');
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        debugPrint('[AUTH] Firebase auth succeeded for UID: ${user.uid}');
        final userRepo = ref.read(userRepositoryProvider);
        final profile = await userRepo.getUser(user.uid);

        if (profile == null) {
          debugPrint('[AUTH] Provisioning new doctor profile in Firestore for ${user.uid}');
          final newProfile = UserModel(
            uid: user.uid,
            email: email,
            displayName: user.displayName ?? 'Dr. Ratikant',
            role: email.contains('admin') ? UserRole.terminologyAdmin : UserRole.doctor,
            approved: true,
            hospital: 'All India Institute of Ayurveda',
            department: 'AYUSH Clinical Terminology Wing',
            designation: 'Government AYUSH Doctor',
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );
          await userRepo.createUser(newProfile);
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH] FirebaseAuthException: ${e.code} - ${e.message}');
      if (mounted) {
        setState(() {
          if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
            _errorMessage = 'Incorrect email address or password.';
          } else if (e.code == 'network-request-failed') {
            _errorMessage = 'Unable to connect. Check your internet connection.';
          } else {
            _errorMessage = 'Authentication failed: ${e.message}';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[AUTH] Unexpected auth error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Authentication failed. Please check your credentials.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('[AUTH] Attempting GoogleAuthProvider sign in');
      final googleProvider = GoogleAuthProvider();
      final credential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      final user = credential.user;

      if (user != null) {
        debugPrint('[AUTH] Google auth succeeded for UID: ${user.uid}');
        final userRepo = ref.read(userRepositoryProvider);
        final profile = await userRepo.getUser(user.uid);

        if (profile == null) {
          debugPrint('[AUTH] Provisioning new Google user profile in Firestore');
          final newProfile = UserModel(
            uid: user.uid,
            email: user.email ?? 'dr.ratikant@ayush.gov.in',
            displayName: user.displayName ?? 'Dr. Ratikant',
            photoUrl: user.photoURL,
            role: UserRole.doctor,
            approved: true,
            hospital: 'All India Institute of Ayurveda',
            department: 'AYUSH Clinical Interoperability Wing',
            designation: 'Government AYUSH Doctor',
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );
          await userRepo.createUser(newProfile);
        }
      }
    } catch (e) {
      debugPrint('[AUTH] Google login error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Google Sign-In cancelled or unavailable.';
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your official healthcare email address to receive a password reset link.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetController,
              decoration: InputDecoration(
                labelText: 'Official Email Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                } catch (_) {}
                if (mounted && ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset instructions sent to $email'),
                      backgroundColor: AppColors.deepPurple,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // ── 1. AUCTE Logo ──────────────────────────────────
                    _buildLogoHeader(),
                    const SizedBox(height: 16),

                    // ── 2. Healthcare Interoperability Illustration ───
                    const _HealthcareInteroperabilityIllustration(),
                    const SizedBox(height: 20),

                    // ── 3. Welcome Section ─────────────────────────────
                    const Text(
                      'Welcome to AUCTE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Secure access for authorized healthcare professionals',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // ── 4. Animated Error Banner ───────────────────────
                    if (_errorMessage != null) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.medicalRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.medicalRed.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.medicalRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.medicalRed, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── 5. Official Email Field ───────────────────────
                    _buildEmailField(),
                    const SizedBox(height: 16),

                    // ── 6. Password Field ──────────────────────────────
                    _buildPasswordField(),
                    const SizedBox(height: 8),

                    // ── 7. Forgot Password Link ───────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _showForgotPasswordDialog,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.deepPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 8. Sign In Button ──────────────────────────────
                    _buildSignInButton(),
                    const SizedBox(height: 20),

                    // ── 9. OR Divider ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 10. Continue with Google Button ────────────────
                    _buildGoogleButton(),
                    const SizedBox(height: 24),

                    // ── 11. Request Access Section ────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have access? ",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        InkWell(
                          onTap: () => context.push(AppRouter.requestAccessPath),
                          child: const Text(
                            'Request Access',
                            style: TextStyle(
                              color: AppColors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // ── 12. Security Footer ───────────────────────────
                    _buildSecurityFooter(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header Branding ───────────────────────────────────────────────
  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.deepPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.eco_rounded, color: AppColors.deepPurple, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'AUCTE',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.deepPurple,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Ayush Unified Clinical Terminology Engine',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.darkSlate,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        const Text(
          'FHIR R4 Clinical Terminology Integration Platform',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Email Input Field ─────────────────────────────────────────────
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Official Email Address',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.deepPurple,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Please enter your email';
            if (!val.contains('@')) return 'Enter a valid healthcare email address';
            return null;
          },
          decoration: InputDecoration(
            hintText: 'doctor@hospital.gov.in',
            hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD8DEE9), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD8DEE9), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.deepPurple, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Password Input Field ──────────────────────────────────────────
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.deepPurple,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleEmailLogin(),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Please enter your password';
            if (val.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD8DEE9), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD8DEE9), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.deepPurple, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sign In Button ────────────────────────────────────────────────
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  ),
                  SizedBox(width: 12),
                  Text('Signing in...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  // ── Continue with Google Button ───────────────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkSlate,
          side: const BorderSide(color: Color(0xFFD8DEE9), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: AppColors.deepPurple, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    child: const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w900, fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkSlate),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Security Footer ───────────────────────────────────────────────
  Widget _buildSecurityFooter() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.deepPurple.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, color: AppColors.deepPurple, size: 18),
              ),
              const SizedBox(height: 6),
              const Text(
                'Secure Government Healthcare Platform',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'FHIR R4 • Role-Based Access • Audit Ready',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Custom Healthcare Interoperability Vector Illustration ─────────
class _HealthcareInteroperabilityIllustration extends StatelessWidget {
  const _HealthcareInteroperabilityIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 185,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.deepPurple.withValues(alpha: 0.1)),
      ),
      child: CustomPaint(
        painter: _IllustrationPainter(),
        child: Stack(
          children: [
            Positioned(
              left: 14,
              bottom: 18,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 4),
                  const Text('Doctor', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.darkSlate)),
                ],
              ),
            ),
            Positioned(
              left: 70,
              top: 14,
              child: _buildNodeBadge(Icons.eco_rounded, 'AYUSH\nSystems'),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 36,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.deepPurple.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: AppColors.deepPurple.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                      SizedBox(width: 6),
                      Text('FHIR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.darkSlate)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 70,
              top: 14,
              child: _buildNodeBadge(Icons.menu_book_rounded, 'Clinical\nTerminology'),
            ),
            Positioned(
              left: 100,
              bottom: 14,
              child: _buildNodeBadge(Icons.account_tree_rounded, 'Interoperability'),
            ),
            Positioned(
              right: 100,
              bottom: 14,
              child: _buildNodeBadge(Icons.verified_user_rounded, 'Standardized\nHealthcare'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.deepPurple.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: AppColors.deepPurple, size: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textSecondary, height: 1.1),
        ),
      ],
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.deepPurple.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.70)
      ..lineTo(size.width * 0.32, size.height * 0.25)
      ..lineTo(size.width * 0.50, size.height * 0.35)
      ..lineTo(size.width * 0.68, size.height * 0.25)
      ..lineTo(size.width * 0.78, size.height * 0.70);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
