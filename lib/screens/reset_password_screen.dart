import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../widgets/custom_textfield.dart';
import '../state/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _resetSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text;

    if (email.isEmpty || newPassword.isEmpty) {
      _showError('Please fill in your email and new password.');
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .resetPassword(email, newPassword);

    if (success && mounted) {
      setState(() => _resetSuccess = true);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    ref.listen(authProvider, (prev, next) {
      if (next.errorMessage != null) {
        _showError(next.errorMessage!);
        ref.read(authProvider.notifier).clearError();
      }
    });

    if (_resetSuccess) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Safe Senior', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 72),
                  const SizedBox(height: 24),
                  Text('Password Reset!', style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 16),
                  Text(
                    'Your password has been successfully updated. You can now log in with your new password.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Safe Senior',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.security, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Title
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Answer your security question to reset',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textDark),
              ),
              const SizedBox(height: 32),
              
              // Form Card with background shield watermark
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Opacity(
                      opacity: 0.03,
                      child: Icon(Icons.shield, size: 200, color: AppTheme.primaryDarkBlue),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wired email field
                        CustomTextField(
                          label: 'Email Address',
                          hintText: 'name@example.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        
                        // Security Question Box — UI-only display per original design
                        Text(
                          'Security Question',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDarkBlue,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLightBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(color: AppTheme.primaryDarkBlue, width: 4),
                            ),
                          ),
                          child: Text(
                            'What was the name of your first pet?',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Security Answer — UI-only, not used in local reset
                        const CustomTextField(
                          label: 'Security Answer',
                          hintText: 'Type your answer here',
                          prefixIcon: Icons.verified_user_outlined,
                        ),
                        const SizedBox(height: 24),
                        
                        // New Password — wired
                        CustomTextField(
                          label: 'New Password',
                          hintText: 'Enter new password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          controller: _newPasswordController,
                          suffixIcon: const Icon(Icons.visibility_outlined),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tip: Use a name and a year that you remember easily.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleReset,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh),
                                      SizedBox(width: 8),
                                      Text('Reset Password'),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Text('Still having trouble?', style: TextStyle(color: AppTheme.textDark)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.headset_mic_outlined),
                label: const Text('Contact Support'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryDarkBlue,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
