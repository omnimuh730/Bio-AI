import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../atoms/water_button.dart';

class HydrationCard extends StatelessWidget {
  const HydrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.water_drop,
                  color: AppColors.accentBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1,250ml', style: AppTextStyles.heading3),
                    Text('Goal: 2,500ml', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
            const Row(
              children: [
                WaterButton(text: '+250'),
                SizedBox(width: 8),
                WaterButton(text: '+500'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
