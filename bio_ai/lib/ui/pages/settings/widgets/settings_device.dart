import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import '../settings_state.dart';

import 'package:bio_ai/ui/pages/settings/core/core_components.dart';

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

class SettingsDeviceRow extends StatelessWidget {
  final DeviceState device;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onToggle;

  const SettingsDeviceRow({
    super.key,
    required this.device,
    required this.icon,
    required this.iconColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.label,
                  style: AppTextStyles.dmSans14SemiBold.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.connected
                      ? 'Synced: ${device.lastSync.isEmpty ? 'just now' : device.lastSync}'
                      : 'Disconnected',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: device.connected
                        ? AppColors.accentGreen
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SettingsToggleSwitch(
            value: device.connected,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}
