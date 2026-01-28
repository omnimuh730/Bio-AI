import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'analytics_summary_card.dart';

class AnalyticsSummaryGrid extends StatelessWidget {
  const AnalyticsSummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.6,
        children: const [
          AnalyticsSummaryCard(
            icon: Icons.local_fire_department,
            label: 'Calories',
            value: '1,840 / 2,300',
            color: AppColors.kAccentBlue,
            bg: Color(0x1A4B7BFF),
          ),
          AnalyticsSummaryCard(
            icon: Icons.biotech,
            label: 'Protein',
            value: '118g / 140g',
            color: AppColors.kAccentPurple,
            bg: Color(0x1A8B5CF6),
          ),
          AnalyticsSummaryCard(
            icon: Icons.directions_run,
            label: 'Active Burn',
            value: '620 kcal',
            color: AppColors.kAccentGreen,
            bg: Color(0x1A10B981),
          ),
          AnalyticsSummaryCard(
            icon: Icons.nightlight_outlined,
            label: 'Sleep Score',
            value: '74 / 100',
            color: AppColors.kTextSecondary,
            bg: Color(0xFFF1F5F9),
          ),
        ],
      ),
    );
  }
}
