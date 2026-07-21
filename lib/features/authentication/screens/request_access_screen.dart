/// AUCTE — Request Access Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/aucte_primary_button.dart';
import '../models/access_request_model.dart';
import '../../../utils/validators.dart';

class RequestAccessScreen extends ConsumerStatefulWidget {
  const RequestAccessScreen({super.key});

  @override
  ConsumerState<RequestAccessScreen> createState() => _RequestAccessScreenState();
}

class _RequestAccessScreenState extends ConsumerState<RequestAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _hospitalController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _mrnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isLoading = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Get the Firebase user via the FutureProvider/StreamProvider
    // But since this screen is only accessible when FirebaseUser exists, 
    // we can read it synchronously via authRepositoryProvider.
    final user = ref.read(authRepositoryProvider).currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _hospitalController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _mrnController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('Not authenticated');

      final repo = ref.read(accessRequestRepositoryProvider);
      
      final request = AccessRequestModel(
        requestId: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
        uid: user.uid,
        email: _emailController.text,
        displayName: _nameController.text,
        hospital: _hospitalController.text,
        department: _departmentController.text,
        designation: _designationController.text,
        medicalRegistrationNumber: _mrnController.text,
        phone: _phoneController.text,
        reason: _reasonController.text,
        createdAt: DateTime.now(),
      );

      await repo.createRequest(request);

      // Tell auth state notifier to refresh somehow, or just set submitted
      // Currently, the AppAuthState looks at `users` collection.
      // If we just submitted an access request, we are still `authenticatedUnknown`
      // until approved. So we show success locally.
      if (mounted) {
        setState(() {
          _submitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to submit request: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_submitted) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 64, color: AppColors.primaryTeal),
                const SizedBox(height: AppSpacing.xl),
                Text('Request Submitted Successfully', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                Text('Contact your system administrator for approval.', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xxl),
                TextButton(
                  onPressed: () {
                    ref.read(authServiceProvider).signOut();
                  },
                  child: const Text('Return to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        title: const Text('Request Access'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Clinical Verification',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Please provide your details to request access to the terminology platform.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _hospitalController,
                      decoration: const InputDecoration(labelText: 'Hospital Name'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _departmentController,
                      decoration: const InputDecoration(labelText: 'Department'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _designationController,
                      decoration: const InputDecoration(labelText: 'Designation'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _mrnController,
                      decoration: const InputDecoration(labelText: 'Medical Registration Number'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Reason for Access'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    AuctePrimaryButton(
                      label: 'Submit Request',
                      onPressed: _submitRequest,
                      isLoading: _isLoading,
                      icon: Icons.send,
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
}
