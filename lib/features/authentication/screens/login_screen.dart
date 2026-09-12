import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/aucte_logo.dart';
import '../repositories/firebase_auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authRepo = FirebaseAuthRepository.instance;

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final remembered = _authRepo.getRememberedIdentifier();
    if (remembered != null && remembered.isNotEmpty) {
      _identifierController.text = remembered;
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.login(
        identifier: _identifierController.text,
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final practitioner = await _authRepo.signInWithGoogle();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${practitioner.fullName}!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AucteLogo(size: 68))
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms),
                  const SizedBox(height: 18),

                  // Medical Lottie Animation
                  SizedBox(
                    height: 150,
                    child: Lottie.network(
                      'https://assets8.lottiefiles.com/packages/lf20_tutvdkg0.json', // Example medical animation
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.health_and_safety,
                        size: 80,
                        color: AppColors.primary,
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 18),

                  Text(
                    'AUCTE',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 6),

                  Text(
                    'Digital Healthcare Portal',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 28),

                  // ─── Error Message ─────────────────────────────────────
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ─── Email / Practitioner ID ───────────────────────────
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email or Practitioner ID',
                      hintText: 'e.g. practitioner@ayush.gov.in',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email or Practitioner ID';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ─── Password ──────────────────────────────────────────
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // ─── Remember Me ───────────────────────────────────────
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _rememberMe = val ?? true;
                          });
                        },
                      ),
                      Text(
                        'Remember me',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ─── Sign In Button ────────────────────────────────────
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
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
                              'Sign In',
                              style: AppTextStyles.button,
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─── Google Sign-In Button ─────────────────────────────
                  SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: (_isLoading || _isGoogleLoading)
                          ? null
                          : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.surface,
                      ),
                      child: _isGoogleLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primary,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google G icon rendered locally — no network required
                                const _GoogleIcon(),
                                const SizedBox(width: 12),
                                Text(
                                  'Sign in with Google',
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Register Link ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          'Register',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

        ),
      ),
    );
  }
}

/// A locally-rendered Google 'G' icon using pure Flutter Canvas.
/// No network dependency — always available, even offline.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleGPainter(),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue arc (right side)
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.28
      ..strokeCap = StrokeCap.butt;

    // Red arc (top)
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.28
      ..strokeCap = StrokeCap.butt;

    // Yellow arc (bottom-left)
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.28
      ..strokeCap = StrokeCap.butt;

    // Green arc (bottom)
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.28
      ..strokeCap = StrokeCap.butt;

    final arcRadius = radius * 0.72;
    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    // Draw each quadrant arc
    canvas.drawArc(rect, -0.52, 1.04, false, paintBlue);   // right
    canvas.drawArc(rect, -2.62, 1.56, false, paintRed);    // top-left
    canvas.drawArc(rect, 2.27, 0.88, false, paintYellow);  // bottom-left
    canvas.drawArc(rect, 0.52, 1.75, false, paintGreen);   // bottom-right

    // Horizontal bar (blue)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.height * 0.26
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + arcRadius, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
