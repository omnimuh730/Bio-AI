import 'package:flutter/material.dart';
import '../molecules/metric_card.dart';
import '../../core/constants/app_colors.dart';

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
