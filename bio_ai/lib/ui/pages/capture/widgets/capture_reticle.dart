import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/app/di/injectors.dart';

class CaptureReticle extends ConsumerWidget {
  const CaptureReticle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchAsync = ref.watch(pitchProvider);

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.32,
      left: 0,
      right: 0,
      child: Center(
        child: pitchAsync.when(
          data: (deg) {
            final inRange = deg >= 40 && deg <= 50;
            final borderColor = inRange
                ? AppColors.accentGreen
                : Colors.white.withValues(alpha: 0.5);
            return Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 0,
                    spreadRadius: 1000,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.accentBlue,
                            width: 4,
                          ),
                          left: BorderSide(
                            color: AppColors.accentBlue,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.accentBlue,
                            width: 4,
                          ),
                          right: BorderSide(
                            color: AppColors.accentBlue,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: inRange
                              ? AppColors.accentGreen
                              : AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          inRange ? 'Aligned' : 'Hold 40–50°',
                          style: AppTextStyles.overline.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(
            width: 250,
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Container(
            width: 250,
            height: 250,
            color: Colors.black26,
            child: const Center(child: Text('Sensor unavailable')),
          ),
        ),
      ),
    );
  }
}
