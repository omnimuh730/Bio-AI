import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

class VitalsGrid extends StatelessWidget {
  const VitalsGrid({super.key});

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
        children: const [
          MetricCard(
            icon: Icons.monitor_heart,
            title: 'Heart Rate',
            value: '72',
            unit: 'bpm',
            sub: 'Normal Resting',
            iconColor: AppColors.accentBlue,
            stateColor: AppColors.accentGreen,
          ),
          MetricCard(
            icon: Icons.psychology,
            title: 'Stress (HRV)',
            value: '28',
            unit: 'ms',
            sub: 'High Stress',
            iconColor: AppColors.accentOrange,
            stateColor: AppColors.accentOrange,
          ),
          MetricCard(
            icon: Icons.nightlight_round,
            title: 'Sleep Score',
            value: '64',
            unit: '/100',
            sub: 'Suboptimal',
            iconColor: AppColors.accentBlue,
            stateColor: AppColors.accentOrange,
          ),
          MetricCard(
            icon: Icons.directions_walk,
            title: 'Activity',
            value: '2.4k',
            unit: 'steps',
            sub: 'On Track',
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
