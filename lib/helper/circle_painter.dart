import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CirclePainter extends CustomPainter {
  final int numberOfCircles;

  CirclePainter({required this.numberOfCircles});

  @override
  void paint(Canvas canvas, Size size) {
    final paints = [
      Paint()..color = AppColors.coral.withOpacity(0.3),
      Paint()..color = AppColors.teal.withOpacity(0.3),
      Paint()..color = const Color(0xFFFFD700).withOpacity(0.3), // Gold
      Paint()..color = const Color(0xFFBA55D3).withOpacity(0.3), // Medium Orchid
      Paint()..color = const Color(0xFF87CEFA).withOpacity(0.3), // Light Sky Blue
      Paint()..color = const Color(0xFFFFB6C1).withOpacity(0.3), // Light Pink
      Paint()..color = const Color(0xFF98FB98).withOpacity(0.3), // Pale Green
      Paint()..color = const Color(0xFFFFA07A).withOpacity(0.3), // Light Salmon
    ];

    final positions = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.85, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.05),
      Offset(size.width * 0.7, size.height * 0.95),
      Offset(size.width * 0.3, size.height * 0.9),
      Offset(size.width * 0.95, size.height * 0.4),
    ];

    final radii = [40.0, 50.0, 45.0, 55.0, 30.0, 35.0, 60.0, 40.0];

    for (int i = 0; i < numberOfCircles; i++) {
      canvas.drawCircle(
        positions[i % positions.length],
        radii[i % radii.length],
        paints[i % paints.length],
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
