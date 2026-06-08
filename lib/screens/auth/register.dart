import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneForm extends StatefulWidget {
  const PhoneForm({super.key});

  @override
  State<PhoneForm> createState() => _PhoneFormState();
}

class _PhoneFormState extends State<PhoneForm> {
  String? _phone;
  bool _isLoading = false;
  final TextEditingController _phoneInput = TextEditingController();

  @override
  void dispose() {
    _phoneInput.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_phone == null || _phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.auth.signInWithOtp(phone: _phone);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code sent to $_phone')),
      );

      Future.delayed(Duration(seconds: 2), () {
        if (!mounted) return;
        context.go(
          Uri(path: '/verify', queryParameters: {'phone': _phone}).toString(),
        );
      });
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      String errMsg = 'Failed to send code. Try again';
      if (e.toString().contains('SocketException')) {
        errMsg = 'No internet connection';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errMsg)));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Phone number',
          style: textTheme.labelMedium?.copyWith(fontWeight: .bold),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          controller: _phoneInput,
          initialCountryCode: 'GH',
          autofocus: true,
          invalidNumberMessage: 'Invalid phone number',
          onChanged: (text) => _phone = text.completeNumber,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _isLoading ? null : () => _submit(),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send code'),
        ),
      ],
    );
  }
}

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Align(
                  alignment: .topLeft,
                  child: BackButton(
                    onPressed: () {
                      context.go('/');
                    },
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        'Welcome to HomeMed',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter your phone number to get started',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 36),

                      const PhoneForm(),
                    ],
                  ),
                ),

                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: .center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
