import 'package:flutter/material.dart';
import 'package:homemed/model/consultation_request.dart';
import 'package:homemed/widgets/history_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HistorySkeleton extends StatelessWidget {
  final int itemCount;

  const HistorySkeleton({super.key, required this.itemCount});

  static final _dummyRequest = ConsultationRequest(
    id: 'dummy',
    symptoms:
        'Loading symptoms description and details for medical help request...',
    status: 'Pending',
    createdAt: DateTime.now(),
    fileUrls: const ['dummy_file'],
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: ((context, index) {
          return HistoryCard(request: _dummyRequest);
        }),
      ),
    );
  }
}
