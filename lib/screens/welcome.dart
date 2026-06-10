import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Image.asset('assets/images/icon.png', width: 90),
                      Text(
                        'HomeMed',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Medical care without the stress',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  context.push('/register');
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
