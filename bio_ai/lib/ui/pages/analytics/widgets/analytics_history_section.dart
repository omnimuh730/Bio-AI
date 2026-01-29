import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import '../models/analytics_history_entry.dart';
import 'analytics_history_card.dart';

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
