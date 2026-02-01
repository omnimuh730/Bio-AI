import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/settings/core/core_components.dart';

class SettingsDietarySection extends StatelessWidget {
  final ValueChanged<String> onChipTap;

  const SettingsDietarySection({super.key, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    final chips = ['Vegan', 'Keto', 'Paleo', 'Pescatarian', 'Mediterranean'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Dietary Profile'),
        SettingsCardContainer(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: chips
                    .map(
                      (chip) => SettingsSelectableChip(
                        label: chip,
                        onTap: () => onChipTap(chip),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  SettingsInputField(
                    label: 'Allergies',
                    hint: 'Peanuts, Gluten, Dairy',
                  ),
                  SizedBox(height: 12),
                  SettingsInputField(label: 'Dislikes', hint: 'Mushrooms'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
