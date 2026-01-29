import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

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
