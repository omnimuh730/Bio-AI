import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import '../models/device_state.dart';
import 'settings_action_row.dart';
import 'settings_card_container.dart';
import 'settings_device_row.dart';
import 'settings_divider.dart';
import 'settings_section_label.dart';

class SettingsDeviceSection extends StatelessWidget {
  final Map<String, DeviceState> devices;
  final ValueChanged<String> onToggle;
  final VoidCallback onResync;
  final VoidCallback onReauth;
  final VoidCallback onFind;

  const SettingsDeviceSection({
    super.key,
    required this.devices,
    required this.onToggle,
    required this.onResync,
    required this.onReauth,
    required this.onFind,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Device Sync'),
        SettingsCardContainer(
          children: [
            SettingsDeviceRow(
              device: devices['apple']!,
              icon: Icons.apple,
              iconColor: AppColors.textMain,
              onToggle: () => onToggle('apple'),
            ),
            const SettingsDivider(),
            SettingsDeviceRow(
              device: devices['google']!,
              icon: Icons.g_mobiledata,
              iconColor: AppColors.textMain,
              onToggle: () => onToggle('google'),
            ),
            const SettingsDivider(),
            SettingsDeviceRow(
              device: devices['garmin']!,
              icon: Icons.watch,
              iconColor: AppColors.textMain,
              onToggle: () => onToggle('garmin'),
            ),
            const SettingsDivider(),
            SettingsDeviceRow(
              device: devices['fitbit']!,
              icon: Icons.favorite_border,
              iconColor: AppColors.textMain,
              onToggle: () => onToggle('fitbit'),
            ),
            SettingsActionRow(
              label: 'Resync Devices',
              icon: Icons.sync,
              color: AppColors.accentGreen,
              background: const Color(0xFFF0FDF4),
              onTap: onResync,
            ),
            SettingsActionRow(
              label: 'Re-Auth Devices',
              icon: Icons.verified_user_outlined,
              color: AppColors.accentBlue,
              background: const Color(0xFFEEF2FF),
              onTap: onReauth,
            ),
            SettingsActionRow(
              label: 'Find Devices',
              icon: Icons.wifi_tethering,
              color: AppColors.textMain,
              background: const Color(0xFFF8FAFC),
              onTap: onFind,
            ),
          ],
        ),
      ],
    );
  }
}
