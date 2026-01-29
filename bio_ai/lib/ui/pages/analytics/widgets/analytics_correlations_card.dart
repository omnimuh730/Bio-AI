import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'analytics_correlation_chart_painter.dart';
import 'analytics_metric_selector.dart';
import 'analytics_time_toggle.dart';

class AnalyticsCorrelationsCard extends StatelessWidget {
  final String range;
  final ValueChanged<String> onRangeChanged;
  final String metricA;
  final String metricB;
  final Map<String, String> metricLabels;
  final ValueChanged<String> onMetricAChanged;
  final ValueChanged<String> onMetricBChanged;
  final List<double> primary;
  final List<double> secondary;
  final List<String> labels;

  const AnalyticsCorrelationsCard({
    super.key,
    required this.range,
    required this.onRangeChanged,
    required this.metricA,
    required this.metricB,
    required this.metricLabels,
    required this.onMetricAChanged,
    required this.onMetricBChanged,
    required this.primary,
    required this.secondary,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Correlations',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              AnalyticsTimeToggle(selected: range, onChanged: onRangeChanged),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsMetricSelector(
                        label: metricLabels[metricA] ?? 'Metric A',
                        color: AppColors.accentBlue,
                        background: const Color(0x1A4B7BFF),
                        options: metricLabels.keys.take(5).toList(),
                        onSelected: onMetricAChanged,
                        formatter: (key) => metricLabels[key] ?? key,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnalyticsMetricSelector(
                        label: metricLabels[metricB] ?? 'Metric B',
                        color: AppColors.accentPurple,
                        background: const Color(0x1A8B5CF6),
                        options: metricLabels.keys.skip(5).take(5).toList(),
                        onSelected: onMetricBChanged,
                        formatter: (key) => metricLabels[key] ?? key,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: AnalyticsCorrelationChartPainter(
                      primary: primary,
                      secondary: secondary,
                      primaryColor: AppColors.accentBlue,
                      secondaryColor: AppColors.accentPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels
                      .map(
                        (label) => Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
