import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  // Resend countdown
  static const int _initialResendSeconds = 30;
  final _otp = TextEditingController();
  late final SmsRetriever smsRetriever;

  final _otpField = GlobalKey<FormState>();
  String? _phone;
  String? _formatedNumber;
  bool _isLoading = false;
  int _secondsRemaining = _initialResendSeconds;
  bool _isResendAvailable = false;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer(_initialResendSeconds);
    smsRetriever = SmsRetrieverImpl(SmartAuth.instance);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _phone = GoRouterState.of(context).uri.queryParameters['phone'];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    _formatedNumber =
        '+${PhoneNumber.parse(_phone ?? '').countryCode} ${PhoneNumber.parse(_phone ?? '').formatNsn()}';

    final defaultTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(
        fontSize: 20,
        color: colorScheme.onSurface,
        fontWeight: .w600,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: .circular(18),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: .topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded),
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
                      'Verify your number',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: .w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We sent a 6-digit code to $_formatedNumber',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _otpField,
                      child: Pinput(
                        controller: _otp,
                        length: 6,
                        showErrorWhenFocused: true,
                        smsRetriever: smsRetriever,
                        defaultPinTheme: defaultTheme,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'OTP code is required',
                          ),
                          FormBuilderValidators.minLength(
                            6,
                            errorText: 'Code must be 6 digits',
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : () => _verify(),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: (_isResendAvailable && !_isLoading)
                          ? _resend
                          : null,
                      child: Text(
                        _isResendAvailable
                            ? 'Resend code'
                            : 'Resend in ${_formatSeconds(_secondsRemaining)}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSeconds(int seconds) {
    return '$seconds s';
  }

  Future<void> _resend() async {
    if (!_isResendAvailable) return;

    setState(() => _isLoading = true);

    try {
      await supabase.auth.signInWithOtp(phone: _phone);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code sent to $_formatedNumber')),
      );

      // restart countdown
      _startResendTimer(_initialResendSeconds);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      String errMsg = 'Failed to resend code. Try again';
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

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
      _isResendAvailable = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _isResendAvailable = true);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  Future<void> _verify() async {
    if (!_otpField.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await supabase.auth.verifyOTP(
        type: .sms,
        phone: _phone,
        token: _otp.text,
      );

      if (!mounted) return;
      storage.write('phone', _phone);
      context.go('/complete-profile');
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      String errMsg = 'Failed to verify code. Try again';
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

class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeUserConsentApiListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final res = await smartAuth.getSmsWithUserConsentApi();
    return res.data?.code;
  }

  @override
  bool get listenForMultipleSms => false;
}
