import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String? _phone;
  String? _formatedNumber;
  bool _isLoading = false;
  final _phoneField = GlobalKey<FormState>();
  final _phoneCtrl = PhoneController(.parse('233'));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    _formatedNumber =
        '+${p.PhoneNumber.parse(_phone ?? '').countryCode} ${p.PhoneNumber.parse(_phone ?? '').formatNsn()}';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .center,
            children: [
              Column(
                crossAxisAlignment: .center,
                children: [
                  Text(
                    'Enter your number',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: .w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We\'ll send you a 6-digit one-time verification code',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                    textAlign: .center,
                  ),
                ],
              ),
              const SizedBox(height: 36),

              Text(
                'PHONE NUMBER',
                style: textTheme.labelMedium?.copyWith(fontWeight: .bold),
              ),
              const SizedBox(height: 8),
              Form(
                key: _phoneField,
                child: PhoneInput(
                  controller: _phoneCtrl,
                  countrySelectorNavigator: .modalBottomSheet(),
                  defaultCountry: .GH,
                  decoration: const InputDecoration(
                    hintText: '53  333  4444',
                    border: OutlineInputBorder(
                      borderRadius: .all(.circular(16)),
                    ),
                  ),
                  onChanged: (text) => _phone = text!.international,
                  autovalidateMode: .onUserInteractionIfError,
                  validator: PhoneValidator.compose([
                    PhoneValidator.required(errorText: 'Phone number required'),
                    PhoneValidator.valid(errorText: 'Invalid phone number'),
                  ]),
                ),
              ),

              const SizedBox(height: 32),
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_phoneField.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await supabase.auth.signInWithOtp(phone: _phone);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code sent to $_formatedNumber')),
      );

      Future.delayed(Duration(seconds: 2), () {
        if (!mounted) return;
        context.push(
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
        errMsg = 'No internet connection. Try again';
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
}
