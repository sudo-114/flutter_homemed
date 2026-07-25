import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HistorySkeleton extends StatelessWidget {
  final int itemCount;

  const HistorySkeleton({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Bone.text(words: 3),
              subtitle: Bone.text(words: 2),
            ),
          );
        },
      ),
    );
  }
}
