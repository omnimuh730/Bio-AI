import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

import 'package:bio_ai/services/streaming_service.dart';
import 'package:bio_ai/core/config.dart';

class VitalsGrid extends StatefulWidget {
  final StreamingService? streaming;
  const VitalsGrid({super.key, this.streaming});

  @override
  State<VitalsGrid> createState() => _VitalsGridState();
}

class _VitalsGridState extends State<VitalsGrid> {
  Map<String, dynamic> latest = {};
  Map<String, dynamic> _metrics = {};
  String? _deviceName;
  final Map<String, List<double>> _seriesByMetric = {};

  @override
  void initState() {
    super.initState();
    if (AppConfig.isDevOrStage && widget.streaming != null) {
      latest = widget.streaming!.latest.value;
      _deviceName = _resolveDeviceName(latest);
      _metrics = _deviceName == null
          ? <String, dynamic>{}
          : (latest[_deviceName]?['metrics'] as Map<String, dynamic>? ?? {});
      _updateSeries(_metrics);
      widget.streaming!.latest.addListener(_onLatest);
    }
  }

  @override
  void dispose() {
    if (AppConfig.isDevOrStage && widget.streaming != null) {
      widget.streaming!.latest.removeListener(_onLatest);
    }
    super.dispose();
  }

  void _onLatest() {
    final nextLatest = widget.streaming!.latest.value;
    final nextDevice = _resolveDeviceName(nextLatest);
    final nextMetrics = nextDevice == null
        ? <String, dynamic>{}
        : (nextLatest[nextDevice]?['metrics'] as Map<String, dynamic>? ?? {});
    if (_deviceName != nextDevice) {
      _seriesByMetric.clear();
    }
    _updateSeries(nextMetrics);
    setState(() {
      latest = nextLatest;
      _deviceName = nextDevice;
      _metrics = nextMetrics;
    });
  }

  String? _resolveDeviceName(Map<String, dynamic> snapshot) {
    if (snapshot.isEmpty) return null;
    final selected = widget.streaming?.selectedDeviceName;
    if (selected != null && snapshot.containsKey(selected)) return selected;
    return snapshot.keys.first;
  }

  void _updateSeries(Map<String, dynamic> metrics) {
    final keys = metrics.keys.toSet();
    _seriesByMetric.removeWhere((key, _) => !keys.contains(key));
    for (final entry in metrics.entries) {
      final metricData = entry.value;
      final rawValue =
          metricData is Map ? metricData['value'] : metricData;
      final numeric = _toDouble(rawValue);
      if (numeric == null) continue;
      final list = _seriesByMetric.putIfAbsent(entry.key, () => []);
      list.add(numeric);
      if (list.length > 30) {
        list.removeAt(0);
      }
    }
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is num) {
      final abs = value.abs();
      if (abs >= 100 || value == value.roundToDouble()) {
        return value.toStringAsFixed(0);
      }
      if (abs >= 10) return value.toStringAsFixed(1);
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  String _labelForKey(String key) {
    const overrides = {
      'hrv_rmssd': 'HRV RMSSD',
      'spo2': 'SpO2',
      'vo2_max_est': 'VO2 Max Est',
      'ecg_waveform': 'ECG Waveform',
      'gps_track': 'GPS Track',
      'body_temp_dev': 'Body Temp Dev',
    };
    if (overrides.containsKey(key)) return overrides[key]!;
    return key
        .split('_')
        .map((part) {
          if (part.length <= 2) return part.toUpperCase();
          return '${part[0].toUpperCase()}${part.substring(1)}';
        })
        .join(' ');
  }

  IconData _iconForKey(String key) {
    final lower = key.toLowerCase();
    if (lower.contains('heart')) return Icons.monitor_heart;
    if (lower.contains('sleep')) return Icons.nightlight_round;
    if (lower.contains('stress') || lower.contains('hrv')) return Icons.psychology;
    if (lower.contains('oxygen') || lower.contains('spo2'))
      return Icons.bloodtype;
    if (lower.contains('temp')) return Icons.thermostat;
    if (lower.contains('gps') || lower.contains('loc')) return Icons.place;
    if (lower.contains('cadence') || lower.contains('steps'))
      return Icons.directions_walk;
    if (lower.contains('noise')) return Icons.surround_sound;
    return Icons.bolt;
  }

  Color _colorForKey(String key) {
    const palette = [
      AppColors.accentBlue,
      AppColors.accentGreen,
      AppColors.accentOrange,
      AppColors.accentPurple,
      AppColors.accentRed,
      AppColors.accentYellow,
    ];
    final hash = key.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final entries = _metrics.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'No live metrics yet. Connect a device to start streaming.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 360 ? 1 : 2;
    final childAspectRatio = crossAxisCount == 1 ? 2.4 : 1.35;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_deviceName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.sensors,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _deviceName!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          GridView.builder(
            itemCount: entries.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final metricData = entry.value;
              final rawValue =
                  metricData is Map ? metricData['value'] : metricData;
              final unit =
                  metricData is Map ? (metricData['unit'] ?? '') : '';
              final valueText = _formatValue(rawValue);
              final series =
                  List<double>.from(_seriesByMetric[entry.key] ?? const []);
              final color = _colorForKey(entry.key);
              return MetricCard(
                icon: _iconForKey(entry.key),
                title: _labelForKey(entry.key),
                value: valueText,
                unit: unit.toString(),
                sub: 'Live',
                iconColor: color,
                stateColor: color,
                series: series,
              );
            },
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String sub;
  final Color iconColor;
  final Color stateColor;
  final List<double> series;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.sub,
    required this.iconColor,
    required this.stateColor,
    this.series = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: AppTextStyles.heading3),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: series.length > 1
                ? Sparkline(values: series, color: iconColor)
                : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: AppTextStyles.labelSmall.copyWith(color: stateColor),
          ),
        ],
      ),
    );
  }
}

class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;

  const Sparkline({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final range = (maxV - minV).abs();
    final safeRange = range == 0 ? 1 : range;
    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height -
          ((values[i] - minV) / safeRange) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
