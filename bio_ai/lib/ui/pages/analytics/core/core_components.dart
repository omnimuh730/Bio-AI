import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

class AnalyticsTimeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const AnalyticsTimeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: ['W', 'M', '3M']
            .map(
              (label) => GestureDetector(
                onTap: () => onChanged(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected == label
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected == label
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected == label
                          ? AppColors.textMain
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class AnalyticsMetricSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final Color color;
  final Color background;
  final String Function(String) formatter;

  const AnalyticsMetricSelector({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
    required this.color,
    required this.background,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              child: Text(
                formatter(option),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMain,
                ),
              ),
            ),
          )
          .toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      offset: const Offset(0, 42),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

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
    for (final y in [
      size.height * 0.25,
      size.height * 0.5,
      size.height * 0.75,
    ]) {
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
      final step = values.length == 1
          ? size.width
          : size.width / (values.length - 1);
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
      ..color = secondaryColor.withValues(alpha: 0.6)
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
        final segmentLength = distance + dashLength < metric.length
            ? dashLength
            : metric.length - distance;
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
