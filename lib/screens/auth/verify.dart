import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

class OtpForm extends StatefulWidget {
  final String? phone;
  const OtpForm({super.key, this.phone});

  @override
  State<OtpForm> createState() => _OptFormState();
}

class _OptFormState extends State<OtpForm> {
  final _otp = TextEditingController();
  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          widget.phone ?? '',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        Pinput(controller: _otp, length: 6, autofocus: true),
        const SizedBox(height: 24),
        FilledButton(onPressed: () {}, child: const Text('Verify')),
        const SizedBox(height: 12),
        TextButton(onPressed: () {}, child: const Text('Resend code')),
      ],
    );
  }
}

class Verify extends StatelessWidget {
  const Verify({super.key});
  @override
  Widget build(BuildContext context) {
    final phone = GoRouterState.of(context).uri.queryParameters['phone'];
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
                      context.go('/register');
                    },
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        'Verify your number',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter the code sent to this number',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),

                      OtpForm(phone: phone),
                    ],
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
