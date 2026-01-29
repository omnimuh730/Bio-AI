import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/device_state.dart';
import 'settings_toggle_switch.dart';

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
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.connected
                      ? 'Synced: ${device.lastSync.isEmpty ? 'just now' : device.lastSync}'
                      : 'Disconnected',
                  style: GoogleFonts.inter(
                    fontSize: 11,
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
