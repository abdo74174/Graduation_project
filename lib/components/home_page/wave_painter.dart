import 'package:flutter/material.dart';
import 'dart:math' as math;

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double width;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Calculate the position of the curve based on animation
    double curveX = (width / 4) * 3 * animationValue;
    if (curveX < 0) curveX = 0;
    if (curveX > width) curveX = width;

    // Starting point
    path.moveTo(0, size.height);

    // Create curved path
    path.lineTo(0, size.height * 0.6);

    // First curve control points
    path.quadraticBezierTo(
        curveX - 60, size.height * 0.6, curveX - 30, size.height * 0.35);

    // Middle curve
    path.quadraticBezierTo(
        curveX, size.height * 0.2, curveX + 30, size.height * 0.35);

    // End curve
    path.quadraticBezierTo(
        curveX + 60, size.height * 0.6, width, size.height * 0.6);

    // Complete the path
    path.lineTo(width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
