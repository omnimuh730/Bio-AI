import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaptureBottomControls extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onShutterTap;

  const CaptureBottomControls({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onShutterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 40, top: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xCC000000), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _modeButton('scan'),
                const SizedBox(width: 48),
                _modeButton('barcode'),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onShutterTap,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String value) {
    final isActive = mode == value;
    return GestureDetector(
      onTap: () => onModeChanged(value),
      child: Text(
        value.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
          letterSpacing: 1,
        ),
      ),
    );
  }
}
