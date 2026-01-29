import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CaptureTopOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onQuickSwitch;
  final bool quickSwitchOpen;
  final VoidCallback onFlash;
  final VoidCallback onToggleOffline;
  final bool offlineMode;
  final VoidCallback onBarcode;

  const CaptureTopOverlay({
    super.key,
    required this.onClose,
    required this.onQuickSwitch,
    required this.quickSwitchOpen,
    required this.onFlash,
    required this.onToggleOffline,
    required this.offlineMode,
    required this.onBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x99000000), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CaptureIconButton(icon: Icons.close, onTap: onClose),
            Row(
              children: [
                CaptureIconButton(
                  icon: Icons.apps_rounded,
                  onTap: onQuickSwitch,
                  active: quickSwitchOpen,
                ),
                const SizedBox(width: 12),
                CaptureIconButton(icon: Icons.flash_on, onTap: onFlash),
                const SizedBox(width: 12),
                CaptureIconButton(
                  icon: offlineMode
                      ? Icons.signal_wifi_off
                      : Icons.signal_wifi_4_bar,
                  onTap: onToggleOffline,
                  active: offlineMode,
                ),
                const SizedBox(width: 12),
                CaptureIconButton(
                  icon: Icons.qr_code_scanner,
                  onTap: onBarcode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CaptureIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const CaptureIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? const Color(0xCCF59E0B) : const Color(0x33FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? AppColors.textMain : Colors.white),
      ),
    );
  }
}
