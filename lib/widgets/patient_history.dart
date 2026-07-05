import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientHistory extends StatelessWidget {
  const PatientHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _HistoryEmpty(),
        ),
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.history_rounded,
            size: 130,
            color: scheme.onSurfaceVariant.withAlpha(80),
          ),
          const SizedBox(height: 38),
          Text(
            'No history yet',
            style: text.headlineSmall!.copyWith(fontWeight: .bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your past consultations, medical requests, and prescriptions will be listed here',
            textAlign: .center,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => context.push('/request-form'),
            child: const Text('Request medical help'),
          ),
        ],
      ),
    );
  }
}
