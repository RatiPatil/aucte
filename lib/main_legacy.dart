import 'package:flutter/material.dart';

void main() {
  runApp(const AucteApp());
}

// ============================================================
// APP
// ============================================================

class AucteApp extends StatelessWidget {
  const AucteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AUCTE',
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// THEME
// ============================================================

class AppColors {
  static const navy = Color(0xFF071B33);
  static const navy2 = Color(0xFF0C294A);
  static const primary = Color(0xFF087F8C);
  static const primaryDark = Color(0xFF05636D);
  static const mint = Color(0xFFE6F7F5);
  static const green = Color(0xFF1C9B75);
  static const blue = Color(0xFF246BCE);
  static const orange = Color(0xFFF09A42);
  static const red = Color(0xFFE85C62);
  static const background = Color(0xFFF5F8FA);
  static const text = Color(0xFF14273D);
  static const textSoft = Color(0xFF718096);
  static const border = Color(0xFFE5EBF0);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F9FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ============================================================
// MODELS + DEMO DATA
// ============================================================

class Patient {
  final String name;
  final String id;
  final String age;
  final String gender;
  final String phone;
  final String lastVisit;

  const Patient({
    required this.name,
    required this.id,
    required this.age,
    required this.gender,
    required this.phone,
    required this.lastVisit,
  });
}

class Term {
  final String traditionalName;
  final String englishName;
  final String namasteCode;
  final String tm2Code;
  final String tm2Title;
  final String biomedicalCode;
  final String biomedicalTitle;
  final String system;

  const Term({
    required this.traditionalName,
    required this.englishName,
    required this.namasteCode,
    required this.tm2Code,
    required this.tm2Title,
    required this.biomedicalCode,
    required this.biomedicalTitle,
    required this.system,
  });
}

const demoPatients = [
  Patient(
    name: 'Rahul Patil',
    id: 'AUC-P001',
    age: '34',
    gender: 'Male',
    phone: '9876543210',
    lastVisit: 'Today, 09:40 AM',
  ),
  Patient(
    name: 'Anita Sharma',
    id: 'AUC-P002',
    age: '42',
    gender: 'Female',
    phone: '9876501234',
    lastVisit: 'Yesterday',
  ),
  Patient(
    name: 'Priya Verma',
    id: 'AUC-P003',
    age: '29',
    gender: 'Female',
    phone: '9822001122',
    lastVisit: '02 Aug 2026',
  ),
];

/// IMPORTANT:
/// These codes are UI demonstration placeholders only.
/// Replace them later with verified official NAMASTE / WHO mappings.
const demoTerms = [
  Term(
    traditionalName: 'Jvara',
    englishName: 'Fever-related traditional diagnosis',
    namasteCode: 'DEMO-NAM-001',
    tm2Code: 'DEMO-TM2-001',
    tm2Title: 'TM2 mapping pending verification',
    biomedicalCode: 'DEMO-ICD-001',
    biomedicalTitle: 'Biomedical mapping pending verification',
    system: 'Ayurveda',
  ),
  Term(
    traditionalName: 'Kasa',
    englishName: 'Cough-related traditional diagnosis',
    namasteCode: 'DEMO-NAM-002',
    tm2Code: 'DEMO-TM2-002',
    tm2Title: 'TM2 mapping pending verification',
    biomedicalCode: 'DEMO-ICD-002',
    biomedicalTitle: 'Biomedical mapping pending verification',
    system: 'Ayurveda',
  ),
  Term(
    traditionalName: 'Amlapitta',
    englishName: 'Digestive traditional diagnosis',
    namasteCode: 'DEMO-NAM-003',
    tm2Code: 'DEMO-TM2-003',
    tm2Title: 'TM2 mapping pending verification',
    biomedicalCode: 'DEMO-ICD-003',
    biomedicalTitle: 'Biomedical mapping pending verification',
    system: 'Ayurveda',
  ),
];

// ============================================================
// COMMON WIDGETS
// ============================================================

class LogoMark extends StatelessWidget {
  final double size;
  final bool white;

  const LogoMark({super.key, this.size = 52, this.white = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: white ? Colors.white.withValues(alpha: .13) : AppColors.mint,
        borderRadius: BorderRadius.circular(size * .30),
      ),
      child: Icon(
        Icons.health_and_safety_rounded,
        color: white ? Colors.white : AppColors.primary,
        size: size * .58,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 9),
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

// ============================================================
// SPLASH
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.navy2, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const LogoMark(size: 92, white: true),
              const SizedBox(height: 26),
              const Text(
                'AUCTE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  letterSpacing: 5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'AYUSH Unified Clinical\nTerminology Engine',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .78),
                  height: 1.45,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 38),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .15),
                  ),
                ),
                child: const Text(
                  'NAMASTE  ↔  ICD-11  ↔  FHIR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: Text(
                  'Interoperable AYUSH Healthcare',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    letterSpacing: .5,
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

// ============================================================
// ONBOARDING
// ============================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  final pages = const [
    _OnboardData(
      icon: Icons.manage_search_rounded,
      title: 'Unified Terminology',
      subtitle:
          'Search traditional medicine terminology from one clinician-friendly interface.',
    ),
    _OnboardData(
      icon: Icons.hub_rounded,
      title: 'Dual Coding',
      subtitle:
          'Connect NAMASTE terminology with ICD-11 TM2 and biomedical classifications.',
    ),
    _OnboardData(
      icon: Icons.description_rounded,
      title: 'FHIR Ready',
      subtitle:
          'Create interoperable clinical records designed around FHIR R4 workflows.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _goLogin(context),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (value) {
                  setState(() => page = value);
                },
                itemBuilder: (_, index) {
                  final item = pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE5F8F5), Color(0xFFE8F0FC)],
                            ),
                            borderRadius: BorderRadius.circular(52),
                          ),
                          child: Icon(
                            item.icon,
                            size: 82,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 16,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: page == index ? 28 : 8,
                  height: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: page == index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: page == pages.length - 1 ? 'Get Started' : 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (page < pages.length - 1) {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _goLogin(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

// ============================================================
// LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const LogoMark(),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AUCTE',
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        'Clinical Terminology Engine',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue to your clinical workspace.',
                style: TextStyle(fontSize: 15, color: AppColors.textSoft),
              ),
              const SizedBox(height: 34),
              const Text(
                'Email address',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'doctor@example.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: hidePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => hidePassword = !hidePassword);
                    },
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _message(context, 'Firebase password reset comes later.');
                  },
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),

              // Temporary local login
              PrimaryButton(
                text: 'Sign In',
                icon: Icons.login_rounded,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (_) => false,
                  );
                },
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'New to AUCTE?',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Create Practitioner Account',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Prototype authentication • Firebase will be connected next',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.textSoft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER
// ============================================================

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practitioner Registration')),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create your clinical profile',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'For the prototype this creates a local demo session.',
              style: TextStyle(color: AppColors.textSoft),
            ),
            const SizedBox(height: 28),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Registration number',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: 'Ayurveda',
              decoration: const InputDecoration(
                labelText: 'System of medicine',
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'Ayurveda', child: Text('Ayurveda')),
                DropdownMenuItem(value: 'Siddha', child: Text('Siddha')),
                DropdownMenuItem(value: 'Unani', child: Text('Unani')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Institution / Hospital',
                prefixIcon: Icon(Icons.local_hospital_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: 'Create Account',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    DashboardScreen(),
    PatientsScreen(),
    TerminologyScreen(),
    FhirScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.mint,
        onDestinationSelected: (value) {
          setState(() => index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_search_rounded),
            label: 'Terminology',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            label: 'FHIR',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning',
                        style: TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Dr. AUCTE Practitioner',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Badge(
                    child: Icon(Icons.notifications_none_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Hero
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const LogoMark(size: 46, white: true),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF63E6BE),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'SYSTEM READY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Unified Clinical\nTerminology',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bridge NAMASTE, ICD-11 TM2 and biomedical coding in one workflow.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      _StatusChip('NAMASTE'),
                      SizedBox(width: 8),
                      _StatusChip('ICD-11'),
                      SizedBox(width: 8),
                      _StatusChip('FHIR R4'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const SectionTitle('Today at a glance'),
            const SizedBox(height: 12),

            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.people_alt_outlined,
                    value: '12',
                    label: 'Patients',
                    accent: AppColors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.medical_information_outlined,
                    value: '07',
                    label: 'Encounters',
                    accent: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.hub_outlined,
                    value: '18',
                    label: 'Diagnoses',
                    accent: AppColors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.verified_outlined,
                    value: '16',
                    label: 'Dual-coded',
                    accent: AppColors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),
            const SectionTitle('Quick actions'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Add Patient',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPatientScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'New Encounter',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NewEncounterScreen(patient: null),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.manage_search_rounded,
                    title: 'Terminology',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TerminologyScreen(standalone: true),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.code_rounded,
                    title: 'FHIR Preview',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FhirPreviewScreen(term: null),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),
            const SectionTitle('Recent patients'),
            const SizedBox(height: 10),

            ...demoPatients
                .take(3)
                .map((patient) => PatientTile(patient: patient)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;

  const _StatusChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: AppColors.textSoft, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
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

// ============================================================
// PATIENTS
// ============================================================

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = demoPatients.where((patient) {
      return patient.name.toLowerCase().contains(query.toLowerCase()) ||
          patient.id.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPatientScreen()),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            onChanged: (value) {
              setState(() => query = value);
            },
            decoration: const InputDecoration(
              hintText: 'Search patient name or ID',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${filtered.length} patients',
            style: const TextStyle(
              color: AppColors.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...filtered.map((patient) => PatientTile(patient: patient)),
        ],
      ),
    );
  }
}

class PatientTile extends StatelessWidget {
  final Patient patient;

  const PatientTile({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: AppColors.mint,
          child: Text(
            patient.name.substring(0, 1),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          patient.name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${patient.id} • ${patient.age} yrs • ${patient.gender}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailsScreen(patient: patient),
            ),
          );
        },
      ),
    );
  }
}

class PatientDetailsScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.mint,
                  child: Text(
                    patient.name[0],
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient.id,
                  style: const TextStyle(color: AppColors.textSoft),
                ),
                const SizedBox(height: 22),
                const Divider(),
                _InfoRow('Age', '${patient.age} years'),
                _InfoRow('Gender', patient.gender),
                _InfoRow('Phone', patient.phone),
                _InfoRow('Last visit', patient.lastVisit),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Start New Encounter',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewEncounterScreen(patient: patient),
                ),
              );
            },
          ),
          const SizedBox(height: 26),
          const SectionTitle('Clinical history'),
          const SizedBox(height: 12),
          const _EmptyState(
            icon: Icons.history_rounded,
            title: 'No synced encounters yet',
            subtitle:
                'Clinical history will appear here after Firebase is connected.',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSoft),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AddPatientScreen extends StatelessWidget {
  const AddPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Patient information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a local prototype patient record.',
            style: TextStyle(color: AppColors.textSoft),
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Age',
              prefixIcon: Icon(Icons.calendar_month_outlined),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: 'Male',
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc_rounded),
            ),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 14),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            text: 'Create Patient',
            icon: Icons.check_rounded,
            onPressed: () {
              _message(
                context,
                'UI complete. Firebase save will be connected later.',
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ENCOUNTER
// ============================================================

class NewEncounterScreen extends StatelessWidget {
  final Patient? patient;

  const NewEncounterScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Encounter')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (patient != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${patient!.name}\n${patient!.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Icon(Icons.verified_rounded, color: AppColors.green),
                ],
              ),
            ),
          if (patient == null) ...[
            const Text(
              'Select / enter patient',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search patient',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Chief complaint',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const TextField(
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe the primary complaint...',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Clinical notes',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const TextField(
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Enter observations and clinical notes...',
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Continue to Diagnosis',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiagnosisSearchScreen(patient: patient),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DIAGNOSIS + DUAL CODING
// ============================================================

class DiagnosisSearchScreen extends StatefulWidget {
  final Patient? patient;

  const DiagnosisSearchScreen({super.key, this.patient});

  @override
  State<DiagnosisSearchScreen> createState() => _DiagnosisSearchScreenState();
}

class _DiagnosisSearchScreenState extends State<DiagnosisSearchScreen> {
  String query = '';
  String system = 'All';

  @override
  Widget build(BuildContext context) {
    final results = demoTerms.where((term) {
      final matchesQuery =
          term.traditionalName.toLowerCase().contains(query.toLowerCase()) ||
          term.englishName.toLowerCase().contains(query.toLowerCase());

      final matchesSystem = system == 'All' || term.system == system;

      return matchesQuery && matchesSystem;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Diagnosis')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Clinical terminology search',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Search the demo terminology dataset.',
            style: TextStyle(color: AppColors.textSoft),
          ),
          const SizedBox(height: 20),
          TextField(
            autofocus: true,
            onChanged: (value) {
              setState(() => query = value);
            },
            decoration: const InputDecoration(
              hintText: 'Search e.g. Jvara, Kasa...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'Ayurveda', 'Siddha', 'Unani'].map((value) {
              return ChoiceChip(
                label: Text(value),
                selected: system == value,
                onSelected: (_) {
                  setState(() => system = value);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ...results.map(
            (term) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.medical_information_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  term.traditionalName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text('${term.system}\n${term.namasteCode}'),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DualCodingScreen(term: term, patient: widget.patient),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DualCodingScreen extends StatelessWidget {
  final Term term;
  final Patient? patient;

  const DualCodingScreen({super.key, required this.term, this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dual Coding')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navy, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                LogoMark(size: 50, white: true),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUCTE Mapping Engine',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'NAMASTE ↔ ICD-11',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          _CodingCard(
            label: 'TRADITIONAL DIAGNOSIS',
            title: term.traditionalName,
            subtitle: term.englishName,
            code: term.namasteCode,
            source: 'NAMASTE • ${term.system}',
            icon: Icons.spa_outlined,
            color: AppColors.primary,
          ),

          const _MappingArrow(),

          _CodingCard(
            label: 'TRADITIONAL MEDICINE',
            title: term.tm2Title,
            subtitle: 'WHO ICD-11 Traditional Medicine Module 2',
            code: term.tm2Code,
            source: 'ICD-11 TM2',
            icon: Icons.hub_outlined,
            color: AppColors.blue,
          ),

          const _PlusDivider(),

          _CodingCard(
            label: 'BIOMEDICINE',
            title: term.biomedicalTitle,
            subtitle: 'ICD-11 biomedical classification',
            code: term.biomedicalCode,
            source: 'ICD-11',
            icon: Icons.biotech_outlined,
            color: AppColors.orange,
          ),

          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Prototype data only. Medical mappings must be replaced with verified official terminology before clinical use.',
                    style: TextStyle(fontSize: 12, height: 1.45),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Confirm Dual Coding',
            icon: Icons.verified_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConsentScreen(term: term, patient: patient),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CodingCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final String code;
  final String source;
  final IconData icon;
  final Color color;

  const _CodingCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.source,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSoft, height: 1.4),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    code,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  source,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MappingArrow extends StatelessWidget {
  const _MappingArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Center(
        child: Icon(
          Icons.keyboard_double_arrow_down_rounded,
          color: AppColors.primary,
          size: 30,
        ),
      ),
    );
  }
}

class _PlusDivider extends StatelessWidget {
  const _PlusDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.mint,
              child: Icon(Icons.add, size: 18, color: AppColors.primary),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ============================================================
// CONSENT
// ============================================================

class ConsentScreen extends StatefulWidget {
  final Term term;
  final Patient? patient;

  const ConsentScreen({super.key, required this.term, this.patient});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool treatment = true;
  bool recordStorage = true;
  bool analytics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Consent')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.privacy_tip_outlined,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 18),
          const Text(
            'Consent & data use',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Record the patient\'s authorization before creating the interoperable clinical record.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSoft, height: 1.5),
          ),
          const SizedBox(height: 28),
          _ConsentTile(
            title: 'Clinical treatment',
            subtitle: 'Use information for treatment and care',
            value: treatment,
            onChanged: (v) {
              setState(() => treatment = v);
            },
          ),
          _ConsentTile(
            title: 'Health record storage',
            subtitle: 'Store the clinical encounter securely',
            value: recordStorage,
            onChanged: (v) {
              setState(() => recordStorage = v);
            },
          ),
          _ConsentTile(
            title: 'Anonymized analytics',
            subtitle: 'Allow anonymized terminology analytics',
            value: analytics,
            onChanged: (v) {
              setState(() => analytics = v);
            },
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            text: 'Grant Consent & Generate FHIR',
            icon: Icons.lock_rounded,
            onPressed: treatment && recordStorage
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FhirPreviewScreen(term: widget.term),
                      ),
                    );
                  }
                : () {
                    _message(
                      context,
                      'Clinical treatment and record storage consent are required for this prototype workflow.',
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

// ============================================================
// TERMINOLOGY EXPLORER
// ============================================================

class TerminologyScreen extends StatefulWidget {
  final bool standalone;

  const TerminologyScreen({super.key, this.standalone = false});

  @override
  State<TerminologyScreen> createState() => _TerminologyScreenState();
}

class _TerminologyScreenState extends State<TerminologyScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Terminology Explorer',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Explore NAMASTE and mapped ICD-11 concepts.',
          style: TextStyle(color: AppColors.textSoft),
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) {
            setState(() => query = value);
          },
          decoration: const InputDecoration(
            hintText: 'Search terminology',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(
              child: _SourceCard(
                title: 'NAMASTE',
                count: '100',
                icon: Icons.spa_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SourceCard(
                title: 'ICD-11',
                count: 'Mapped',
                icon: Icons.public_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        ...demoTerms
            .where(
              (term) =>
                  term.traditionalName.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  term.englishName.toLowerCase().contains(query.toLowerCase()),
            )
            .map((term) => PatientLikeTermTile(term: term)),
      ],
    );

    if (widget.standalone) {
      return Scaffold(appBar: AppBar(), body: content);
    }

    return Scaffold(body: SafeArea(child: content));
  }
}

class _SourceCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;

  const _SourceCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
            count,
            style: const TextStyle(color: AppColors.textSoft, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class PatientLikeTermTile extends StatelessWidget {
  final Term term;

  const PatientLikeTermTile({super.key, required this.term});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(
          term.traditionalName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${term.system} • ${term.namasteCode}'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DualCodingScreen(term: term)),
          );
        },
      ),
    );
  }
}

// ============================================================
// FHIR
// ============================================================

class FhirScreen extends StatelessWidget {
  const FhirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'FHIR Workspace',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'FHIR R4 clinical interoperability preview.',
              style: TextStyle(color: AppColors.textSoft),
            ),
            const SizedBox(height: 24),
            const _FhirStat(
              icon: Icons.description_outlined,
              title: 'Condition Resources',
              value: '16',
            ),
            const _FhirStat(
              icon: Icons.inventory_2_outlined,
              title: 'Encounter Bundles',
              value: '07',
            ),
            const _FhirStat(
              icon: Icons.verified_user_outlined,
              title: 'Validated',
              value: '100%',
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Open FHIR Preview',
              icon: Icons.code_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FhirPreviewScreen(term: null),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FhirStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _FhirStat({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class FhirPreviewScreen extends StatelessWidget {
  final Term? term;

  const FhirPreviewScreen({super.key, this.term});

  String get json {
    final selected = term ?? demoTerms.first;

    return '''{
  "resourceType": "Condition",
  "id": "aucte-demo-condition",
  "clinicalStatus": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
        "code": "active"
      }
    ]
  },
  "subject": {
    "reference": "Patient/AUC-P001"
  },
  "code": {
    "coding": [
      {
        "system": "urn:aucte:demo:namaste",
        "code": "${selected.namasteCode}",
        "display": "${selected.traditionalName}"
      },
      {
        "system": "urn:aucte:demo:icd11-tm2",
        "code": "${selected.tm2Code}",
        "display": "${selected.tm2Title}"
      },
      {
        "system": "urn:aucte:demo:icd11-biomedicine",
        "code": "${selected.biomedicalCode}",
        "display": "${selected.biomedicalTitle}"
      }
    ]
  }
}''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FHIR R4 Preview')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.green,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Condition resource generated for prototype demonstration.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: SelectableText(
              json,
              style: const TextStyle(
                color: Color(0xFFE6EDF5),
                fontFamily: 'monospace',
                height: 1.5,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            text: 'Complete Encounter',
            icon: Icons.check_circle_rounded,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  icon: const Icon(
                    Icons.verified_rounded,
                    size: 48,
                    color: AppColors.green,
                  ),
                  title: const Text('Encounter Ready'),
                  content: const Text(
                    'The prototype dual-coded FHIR record has been generated successfully.',
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    FilledButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainShell()),
                          (_) => false,
                        );
                      },
                      child: const Text('Back to Dashboard'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.mint,
                    child: Icon(
                      Icons.person_rounded,
                      size: 45,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Dr. AUCTE Practitioner',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ayurveda • Demo Practitioner',
                    style: TextStyle(color: AppColors.textSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _ProfileOption(
              icon: Icons.badge_outlined,
              title: 'Practitioner Details',
            ),
            const _ProfileOption(
              icon: Icons.security_outlined,
              title: 'Security & Access',
            ),
            const _ProfileOption(
              icon: Icons.history_rounded,
              title: 'Audit History',
            ),
            const _ProfileOption(
              icon: Icons.sync_rounded,
              title: 'Terminology Version',
            ),
            const _ProfileOption(
              icon: Icons.info_outline_rounded,
              title: 'About AUCTE',
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileOption({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE + HELPERS
// ============================================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textSoft),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSoft, height: 1.4),
          ),
        ],
      ),
    );
  }
}

void _message(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
