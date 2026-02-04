import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import '../settings_state.dart';

import 'package:bio_ai/ui/pages/settings/core/core_components.dart';

class SettingsDeviceSection extends StatelessWidget {
  final Map<String, DeviceState> devices;
  final List<String> availableDevices;
  final ValueChanged<String> onToggle;
  final VoidCallback onResync;
  final VoidCallback onReauth;
  final VoidCallback onFind;

  const SettingsDeviceSection({
    super.key,
    required this.devices,
    this.availableDevices = const [],
    required this.onToggle,
    required this.onResync,
    required this.onReauth,
    required this.onFind,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvailable = availableDevices.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Device Sync'),
        SettingsCardContainer(
          children: [
            if (!hasAvailable) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Text(
                  'No connected devices',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ] else ...[
              // Show rows for available devices (preserve order)
              for (var i = 0; i < availableDevices.length; i++) ...[
                SettingsDeviceRow(
                  device: devices[availableDevices[i]]!,
                  icon: _iconForDevice(availableDevices[i]),
                  iconColor: AppColors.textMain,
                  onToggle: () => onToggle(availableDevices[i]),
                ),
                if (i != availableDevices.length - 1) const SettingsDivider(),
              ],
            ],

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

  IconData _iconForDevice(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('apple')) return Icons.apple;
    if (lower.contains('fitbit')) return Icons.favorite_border;
    if (lower.contains('google')) return Icons.g_mobiledata;
    if (lower.contains('oura')) return Icons.g_mobiledata;
    return Icons.watch;
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
