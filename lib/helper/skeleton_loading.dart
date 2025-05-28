import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 16.0,
            color: Colors.white,
          ),
          const SizedBox(height: 8.0),
          Container(
            width: 200.0,
            height: 16.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}