import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

class CaptureOfflineBanner extends StatelessWidget {
  final bool visible;

  const CaptureOfflineBanner({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 110,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xDD0F172A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Offline mode. Uploads will queue.',
            style: AppTextStyles.labelSmall,
          ),
        ),
      ),
    );
  }
}
