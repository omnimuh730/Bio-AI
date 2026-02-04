import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/ui/pages/analytics/core/core_components.dart';

class AnalyticsScoreCard extends StatelessWidget {
  const AnalyticsScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 90,
              child: CustomPaint(
                painter: AnalyticsGaugePainter(
                  progress: 0.88,
                  background: const Color(0xFFF1F5F9),
                  foreground: AppColors.accentBlue,
                ),
                child: const SizedBox(width: 180, height: 90),
              ),
            ),
            Text(
              '88',
              style: AppTextStyles.heading1.copyWith(color: AppColors.textMain),
            ),
            Text(
              'Excellent Energy',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.accentBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Trend up: Your score improved by 12% this week. '
                      'Consistent protein intake post-workout has improved your recovery speed.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
