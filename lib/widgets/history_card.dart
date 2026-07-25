import 'package:flutter/material.dart';
import 'package:homemed/model/consultation_request.dart';

class HistoryCard extends StatelessWidget {
  final ConsultationRequest request;
  const HistoryCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(request.symptoms)));
  }
}
