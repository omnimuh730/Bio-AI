import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/settings/core/core_components.dart';

class SettingsGoalSection extends StatelessWidget {
  final List<SettingsGoalItem> goals;
  final ValueChanged<String> onGoalTap;

  const SettingsGoalSection({
    super.key,
    required this.goals,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Goal Setting'),
        SettingsCardContainer(
          children: goals
              .map(
                (goal) => SettingsGoalOption(
                  title: goal.title,
                  selected: goal.selected,
                  onTap: () => onGoalTap(goal.title),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
