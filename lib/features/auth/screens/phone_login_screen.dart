import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  String? _phoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      _phoneNumber = _phoneController.text.trim();
      await authService.signInWithPhone(_phoneNumber!);
      
      setState(() {
        _otpSent = true;
      });
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _handleVerifyOTP() async {
    if (_otpController.text.isEmpty) {
      ref.read(authErrorProvider.notifier).state = 'Please enter OTP';
      return;
    }

    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyOTP(
        phone: _phoneNumber!,
        token: _otpController.text.trim(),
      );
      
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _otpSent ? _buildOTPView(isLoading, error) : _buildPhoneView(isLoading, error),
        ),
      ),
    );
  }

  Widget _buildPhoneView(bool isLoading, String? error) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          
          Icon(
            Icons.phone_android,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          
          Text(
            'Phone Login',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          Text(
            'Enter your phone number to receive a verification code',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Error Message
          if (error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Text(
                error,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          
          // Phone Field
          AuthTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hintText: '+1234567890',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (!value.startsWith('+')) {
                return 'Phone number must start with country code (+)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Send OTP Button
          AuthButton(
            onPressed: isLoading ? null : _handleSendOTP,
            isLoading: isLoading,
            child: const Text('Send OTP'),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPView(bool isLoading, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        
        Icon(
          Icons.sms,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 24),
        
        Text(
          'Verify OTP',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        
        Text(
          'Enter the 6-digit code sent to $_phoneNumber',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Error Message
        if (error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        
        // OTP Field
        AuthTextField(
          controller: _otpController,
          label: 'OTP Code',
          hintText: '000000',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.security,
          textAlign: TextAlign.center,
          maxLength: 6,
        ),
        const SizedBox(height: 24),
        
        // Verify Button
        AuthButton(
          onPressed: isLoading ? null : _handleVerifyOTP,
          isLoading: isLoading,
          child: const Text('Verify & Login'),
        ),
        const SizedBox(height: 16),
        
        // Resend OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive code? ",
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _otpSent = false;
                  _otpController.clear();
                });
                ref.read(authErrorProvider.notifier).state = null;
              },
              child: const Text('Resend'),
            ),
          ],
        ),
      ],
    );
  }
}
