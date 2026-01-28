import 'package:flutter/material.dart';
import 'settings_unit_card.dart';

class SettingsUnitPreview extends StatelessWidget {
  final bool metricUnits;

  const SettingsUnitPreview({super.key, required this.metricUnits});

  @override
  Widget build(BuildContext context) {
    final weight = metricUnits ? '72 kg' : '159 lb';
    final height = metricUnits ? '172 cm' : '5 ft 8 in';
    final water = metricUnits ? '2,500 ml' : '84 oz';
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      children: [
        SettingsUnitCard(label: 'Weight', value: weight),
        SettingsUnitCard(label: 'Height', value: height),
        SettingsUnitCard(label: 'Water Goal', value: water),
        const SettingsUnitCard(label: 'Active Burn', value: '620 kcal'),
      ],
    );
  }
}
