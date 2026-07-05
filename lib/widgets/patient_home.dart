import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientHome extends StatelessWidget {
  const PatientHome({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorscheme = Theme.of(context).colorScheme;
    final name = storage.read('name');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Hello, $name',
                style: textTheme.headlineSmall?.copyWith(fontWeight: .bold),
              ),
              const SizedBox(height: 4),
              Text(
                'How can we help you today?',
                style: TextStyle(color: colorscheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              _EmergencyBanner(),
              const SizedBox(height: 24),
              _RequestHelpCard(onTap: () => context.push('/request-form')),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: .bold,
                      color: colorscheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/patient/history'),
                    child: const Text('View all'),
                  ),
                ],
              ),
              _EmptyActivity(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        launchUrl(Uri.parse('tel:911'));
      },
      borderRadius: .circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: scheme.surface, shape: .circle),
              child: Icon(
                Icons.warning_amber_rounded,
                color: scheme.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Emergency?',
                    style: text.bodyMedium?.copyWith(
                      fontWeight: .w600,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Call an ambulance now',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestHelpCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RequestHelpCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: .circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: .circular(8),
        ),
        child: Column(
          children: [
            Text(
              'Request Medical Help',
              style: text.bodyLarge?.copyWith(
                color: scheme.onPrimary,
                fontWeight: .bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Describe symptoms and get matched with a doctor',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: scheme.onPrimary.withAlpha(220),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          Text(
            'No activity yet',
            style: text.bodyLarge?.copyWith(fontWeight: .bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your consultations, requests, and prescriptions will appear here.',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
