import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/ui/pages/analytics/analytics_state.dart';

class AnalyticsHistorySection extends StatelessWidget {
  final List<AnalyticsHistoryEntry> history;
  final ValueChanged<AnalyticsHistoryEntry> onEdit;

  const AnalyticsHistorySection({
    super.key,
    required this.history,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's History", style: AppTextStyles.dmSans16Bold),
          const SizedBox(height: 12),
          Column(
            children: history
                .map(
                  (entry) => AnalyticsHistoryCard(
                    entry: entry,
                    onEdit: () => onEdit(entry),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class AnalyticsHistoryCard extends StatelessWidget {
  final AnalyticsHistoryEntry entry;
  final VoidCallback onEdit;

  const AnalyticsHistoryCard({
    super.key,
    required this.entry,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      entry.hour,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      entry.meridiem,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: AppTextStyles.dmSans14SemiBold.copyWith(
                      color: AppColors.textMain,
                    ),
                  ),
                  Text(
                    entry.subtitle,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.value,
                style: AppTextStyles.dmSans14SemiBold.copyWith(
                  color: entry.valueColor,
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Edit',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentBlue,
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
