import 'dart:math';
import 'package:flutter/material.dart';

class AnalyticsCorrelationChartPainter extends CustomPainter {
  final List<double> primary;
  final List<double> secondary;
  final Color primaryColor;
  final Color secondaryColor;

  AnalyticsCorrelationChartPainter({
    required this.primary,
    required this.secondary,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (final y in [size.height * 0.25, size.height * 0.5, size.height * 0.75]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final all = [...primary, ...secondary];
    if (all.isEmpty) {
      return;
    }
    final minVal = all.reduce(min);
    final maxVal = all.reduce(max);
    final range = (maxVal - minVal).abs() < 0.0001 ? 1.0 : maxVal - minVal;

    Path makePath(List<double> values) {
      if (values.isEmpty) {
        return Path();
      }
      final step = values.length == 1 ? size.width : size.width / (values.length - 1);
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = step * i;
        final ratio = (values[i] - minVal) / range;
        final y = size.height - (ratio * size.height);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final secondaryPaint = Paint()
      ..color = secondaryColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(makePath(primary), primaryPaint);
    _drawDashedPath(canvas, makePath(secondary), secondaryPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 6.0;
    const dashGap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segmentLength =
            distance + dashLength < metric.length ? dashLength : metric.length - distance;
        final extract = metric.extractPath(distance, distance + segmentLength);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnalyticsCorrelationChartPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
