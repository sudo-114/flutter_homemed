import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneForm extends StatefulWidget {
  const PhoneForm({super.key});

  @override
  State<PhoneForm> createState() => _PhoneFormState();
}

class _PhoneFormState extends State<PhoneForm> {
  String? _phone;
  bool _isLoading = false;

  void _submit() {
    try {
      if (_phone!.isNotEmpty) {
        print(_phone);
        setState(() {
          _isLoading = true;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Phone number',
          style: textTheme.labelMedium?.copyWith(fontWeight: .bold),
        ),
        SizedBox(height: 8),
        IntlPhoneField(
          initialCountryCode: 'GH',
          onChanged: (text) => _phone = text.completeNumber,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => _submit(),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorTheme.onPrimary,
                  ),
                )
              : const Text('Continue'),
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
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Align(
                  alignment: .topLeft,
                  child: BackButton(
                    onPressed: () {
                      context.pop();
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
                      SizedBox(height: 36),

                      PhoneForm(),
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
