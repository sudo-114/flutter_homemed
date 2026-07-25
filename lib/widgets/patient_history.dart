import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:homemed/model/consultation_request.dart';
import 'package:homemed/widgets/history_card.dart';
import 'package:homemed/widgets/history_skeleton.dart';

class PatientHistory extends StatefulWidget {
  const PatientHistory({super.key});
  @override
  State<PatientHistory> createState() => _PatientHistoryState();
}

class _PatientHistoryState extends State<PatientHistory> {
  late final String userId;
  late final Stream<List<Map<String, dynamic>>> stream;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser!.id;
    stream = supabase
        .from('consultation_requests')
        .stream(primaryKey: ['id'])
        .eq('patient_id', userId as Object)
        .order('created_at');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: ((_, snapshot) {
        final data = snapshot.data ?? [];
        bool hasItems =
            (snapshot.hasData && snapshot.data!.isNotEmpty) ||
            (snapshot.connectionState == .waiting);

        return Scaffold(
          appBar: hasItems
              ? AppBar(
                  centerTitle: false,
                  title: const Text(
                    'History',
                    style: TextStyle(fontWeight: .bold),
                  ),
                )
              : null,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Builder(
                builder: (_) {
                  if (snapshot.connectionState == .waiting) {
                    return HistorySkeleton(itemCount: 7);
                  }

                  if (snapshot.hasError) return _ErrorHistory();

                  if (data.isEmpty) return _HistoryEmpty();

                  final request = data
                      .map((r) => ConsultationRequest.fromMap(r))
                      .toList();

                  return ListView(
                    children: request.map((req) {
                      return HistoryCard(request: req);
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: .center,
      children: [
        const SizedBox(height: 100),
        Icon(
          Icons.cloud_off_rounded,
          size: 130,
          color: scheme.onSurfaceVariant.withAlpha(80),
        ),
        const SizedBox(height: 38),
        Text(
          "Couldn't load history",
          style: text.headlineSmall!.copyWith(fontWeight: .bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "We're having trouble retrieving your records. Please check your internet connection",
          textAlign: .center,
        ),
      ],
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
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
    );
  }
}
