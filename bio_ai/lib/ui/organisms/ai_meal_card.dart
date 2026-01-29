import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class AIMealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onSwap;
  final VoidCallback onLog;

  const AIMealCard({
    super.key,
    required this.meal,
    required this.onSwap,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.1)),

        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal['time'], style: AppTextStyles.label),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (meal['badgeColor'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, size: 12, color: meal['badgeColor']),
                    const SizedBox(width: 6),
                    Text(
                      meal['badge'],
                      style: AppTextStyles.overline.copyWith(
                        color: meal['badgeColor'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Body
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  meal['image'],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) =>
                      const Icon(Icons.broken_image),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal['title'], style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(meal['macros'], style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Accordion
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              collapsedBackgroundColor: const Color(0xFFF8FAFC),
              backgroundColor: const Color(0xFFEEF2FF),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.accentBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).whyThis,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    meal['why'],
                    style: AppTextStyles.body.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Buttons
          Row(
            children: [
              GestureDetector(
                onTap: onSwap,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onLog,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accentBlue,
                          Color(0xFF2563EB),
                        ], // Slight gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).eatThisCals(meal['cals'] as int),
                          style: AppTextStyles.button,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
