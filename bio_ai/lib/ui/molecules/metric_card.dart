import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

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
