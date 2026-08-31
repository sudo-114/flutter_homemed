import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:homemed/shared/models/consultation_request.dart';
import 'package:homemed/shared/widgets/history_card.dart';
import 'package:homemed/shared/widgets/history_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';

final ValueNotifier<String> patientNameNotifier = ValueNotifier(
  storage.read('name') ?? '',
);

class PatientHome extends StatelessWidget {
  const PatientHome({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorscheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              _UserName(),
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
                    style: textTheme.titleLarge?.copyWith(fontWeight: .bold),
                  ),
                  TextButton(
                    onPressed: () => context.go('/patient/history'),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(child: _RecentActivity()),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: patientNameNotifier,
      builder: (context, userName, _) {
        final name = userName.split(' ').firstOrNull;
        return Text(
          'Hello, $name',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: .bold),
        );
      },
    );
  }
}

class _RecentActivity extends StatefulWidget {
  @override
  State<_RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<_RecentActivity> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ConsultationRequest.stream(),
      builder: ((context, snapshot) {
        final cached = ConsultationRequest.getCachedRawRequests();
        final rawData = (snapshot.hasData ? snapshot.data! : cached)
            .take(4)
            .toList();

        final isFirstWaiting =
            snapshot.connectionState == .waiting && rawData.isEmpty;
        final hasErrorWithNoData = snapshot.hasError && rawData.isEmpty;

        if (isFirstWaiting) {
          return HistorySkeleton(itemCount: 5);
        }

        if (hasErrorWithNoData) return _ErrorActivity();

        if (rawData.isEmpty) return _EmptyActivity();

        final request = rawData
            .map((r) => ConsultationRequest.fromMap(r))
            .toList();

        return ListView(
          children: request.map((req) {
            return HistoryCard(request: req);
          }).toList(),
        );
      }),
    );
  }
}

class _ErrorActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Text(
            "Couldn't load activity",
            style: text.bodyLarge!.copyWith(fontWeight: .bold),
          ),
          const SizedBox(height: 8),
          Text(
            "We're having trouble retrieving your recent records. Please check your internet connection.",
            textAlign: TextAlign.center,
            style: text.bodySmall!.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Text(
            'No activity yet',
            style: text.bodyLarge!.copyWith(fontWeight: .bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your consultations, requests, and prescriptions will appear here.',
            textAlign: TextAlign.center,
            style: text.bodySmall!.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
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
        width: .infinity,
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
        width: .infinity,
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
