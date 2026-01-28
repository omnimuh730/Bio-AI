import 'package:flutter/material.dart';
import 'settings_card_container.dart';
import 'settings_divider.dart';
import 'settings_section_label.dart';
import 'settings_switch_row.dart';
import 'settings_unit_preview.dart';
import 'settings_unit_toggle.dart';

class SettingsPreferenceSection extends StatelessWidget {
  final bool metricUnits;
  final ValueChanged<bool> onMetricChanged;
  final bool notificationsOn;
  final ValueChanged<bool> onNotificationsChanged;
  final bool offlineOn;
  final ValueChanged<bool> onOfflineChanged;

  const SettingsPreferenceSection({
    super.key,
    required this.metricUnits,
    required this.onMetricChanged,
    required this.notificationsOn,
    required this.onNotificationsChanged,
    required this.offlineOn,
    required this.onOfflineChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Preferences'),
        SettingsCardContainer(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SettingsUnitToggle(
                    metricUnits: metricUnits,
                    onChanged: onMetricChanged,
                  ),
                  const SizedBox(height: 16),
                  SettingsUnitPreview(metricUnits: metricUnits),
                ],
              ),
            ),
            SettingsSwitchRow(
              title: 'Notifications',
              subtitle: 'Smart reminders and bio alerts.',
              value: notificationsOn,
              onChanged: onNotificationsChanged,
            ),
            const SettingsDivider(),
            SettingsSwitchRow(
              title: 'Offline Mode',
              subtitle: 'Queue uploads and cache today plan.',
              value: offlineOn,
              onChanged: onOfflineChanged,
            ),
          ],
        ),
      ],
    );
  }
}
