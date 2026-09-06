import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConnectionRequired extends StatelessWidget {
  const ConnectionRequired({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 130,
                color: scheme.onSurfaceVariant.withAlpha(80),
              ),
              const SizedBox(height: 38),
              Text(
                "Couldn't verify your account",
                style: text.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "We're having trouble reaching our servers. Please check your internet connection and try again.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
