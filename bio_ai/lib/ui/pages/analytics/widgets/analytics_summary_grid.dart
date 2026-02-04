import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

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
            color: AppColors.accentBlue,
            bg: Color(0x1A4B7BFF),
          ),
          AnalyticsSummaryCard(
            icon: Icons.biotech,
            label: 'Protein',
            value: '118g / 140g',
            color: AppColors.accentPurple,
            bg: Color(0x1A8B5CF6),
          ),
          AnalyticsSummaryCard(
            icon: Icons.directions_run,
            label: 'Active Burn',
            value: '620 kcal',
            color: AppColors.accentGreen,
            bg: Color(0x1A10B981),
          ),
          AnalyticsSummaryCard(
            icon: Icons.nightlight_outlined,
            label: 'Sleep Score',
            value: '74 / 100',
            color: AppColors.textSecondary,
            bg: Color(0xFFF1F5F9),
          ),
        ],
      ),
    );
  }
}

class AnalyticsSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const AnalyticsSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.dmSans16Bold.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
