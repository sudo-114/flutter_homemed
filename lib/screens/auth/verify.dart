import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinput/pinput.dart';

class OtpForm extends StatefulWidget {
  final String? phone;
  const OtpForm({super.key, this.phone});

  @override
  State<OtpForm> createState() => _OptFormState();
}

class _OptFormState extends State<OtpForm> {
  final _otp = TextEditingController();
  bool _isLoading = false;

  // Resend countdown
  static const int _initialResendSeconds = 30;
  int _secondsRemaining = _initialResendSeconds;
  bool _isResendAvailable = false;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer(_initialResendSeconds);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otp.dispose();
    super.dispose();
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

  String _formatSeconds(int seconds) {
    return '$seconds s';
  }

  Future<void> _resend() async {
    if (!_isResendAvailable) return;

    setState(() => _isLoading = true);

    try {
      await supabase.auth.signInWithOtp(phone: widget.phone);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code sent to ${widget.phone}')),
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

  Future<void> _verify() async {
    if (_otp.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter OTP code')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.auth.verifyOTP(
        type: .sms,
        phone: widget.phone,
        token: _otp.text,
      );

      if (!mounted) return;
      storage.write('phone', widget.phone);
      context.go('/complete-profile');
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      String errMsg = 'Failed to verify code. Try again';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          widget.phone ?? '',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        Pinput(
          controller: _otp,
          length: 6,
          autofocus: true,
          onCompleted: (value) => _verify(),
        ),
        const SizedBox(height: 24),
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
          onPressed: (_isResendAvailable && !_isLoading) ? _resend : null,
          child: Text(
            _isResendAvailable
                ? 'Resend code'
                : 'Resend in ${_formatSeconds(_secondsRemaining)}',
          ),
        ),
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
