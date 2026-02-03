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

  @override
  void initState() {
    super.initState();
    if (AppConfig.isDevOrStage && widget.streaming != null) {
      latest = widget.streaming!.latest.value;
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
    setState(() {
      latest = widget.streaming!.latest.value;
    });
  }

  String _metric(String key, String metricName, String defaultValue) {
    // Prefer metrics from the selected device, if set
    if (widget.streaming != null &&
        widget.streaming!.selectedDeviceName != null) {
      final sel = widget.streaming!.selectedDeviceName!;
      final d = latest[sel];
      if (d != null) {
        final metrics = d['metrics'] as Map<String, dynamic>?;
        if (metrics != null && metrics.containsKey(metricName)) {
          return '${metrics[metricName]['value']}';
        }
      }
    }

    // Fallback: find first device that has the metric
    for (final d in latest.values) {
      final metrics = d['metrics'] as Map<String, dynamic>?;
      if (metrics != null && metrics.containsKey(metricName)) {
        return '${metrics[metricName]['value']}';
      }
    }
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.4,
        children: [
          MetricCard(
            icon: Icons.monitor_heart,
            title: 'Heart Rate',
            value: _metric('heart', 'heart_rate', '72'),
            unit: 'bpm',
            sub: 'Live',
            iconColor: AppColors.accentBlue,
            stateColor: AppColors.accentGreen,
          ),
          MetricCard(
            icon: Icons.psychology,
            title: 'Stress (HRV)',
            value: _metric('stress', 'hrv_rmssd', '28'),
            unit: 'ms',
            sub: 'Live',
            iconColor: AppColors.accentOrange,
            stateColor: AppColors.accentOrange,
          ),
          MetricCard(
            icon: Icons.nightlight_round,
            title: 'Sleep Score',
            value: _metric('sleep', 'sleep_score', '64'),
            unit: '/100',
            sub: 'Live',
            iconColor: AppColors.accentBlue,
            stateColor: AppColors.accentOrange,
          ),
          MetricCard(
            icon: Icons.directions_walk,
            title: 'Activity',
            value: _metric('activity', 'cadence', '2.4k'),
            unit: 'steps',
            sub: 'Live',
            iconColor: AppColors.accentBlue,
            stateColor: AppColors.accentBlue,
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

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.sub,
    required this.iconColor,
    required this.stateColor,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.label),
            ],
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: AppTextStyles.heading3),
                TextSpan(
                  text: ' $unit',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            sub,
            style: AppTextStyles.labelSmall.copyWith(color: stateColor),
          ),
        ],
      ),
    );
  }
}
