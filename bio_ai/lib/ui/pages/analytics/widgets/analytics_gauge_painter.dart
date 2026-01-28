import 'dart:math';
import 'package:flutter/material.dart';

class AnalyticsGaugePainter extends CustomPainter {
  final double progress;
  final Color background;
  final Color foreground;

  AnalyticsGaugePainter({
    required this.progress,
    required this.background,
    required this.foreground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height);
    final rect = Rect.fromCircle(center: center, radius: radius - 8);

    stroke.color = background;
    canvas.drawArc(rect, pi, pi, false, stroke);

    stroke.color = foreground;
    canvas.drawArc(rect, pi, pi * progress, false, stroke);
  }

  @override
  bool shouldRepaint(covariant AnalyticsGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.background != background ||
        oldDelegate.foreground != foreground;
  }
}
