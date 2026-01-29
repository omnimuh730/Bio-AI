import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';

class AnalyticsEmptyState extends StatelessWidget {
  final VoidCallback onLoadDemo;

  const AnalyticsEmptyState({super.key, required this.onLoadDemo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x224B7BFF), Colors.transparent],
              ),
            ),
            child: const Icon(Icons.eco, color: AppColors.accentBlue, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Gathering your bio-data...', style: AppTextStyles.dmSans16Bold),
          const SizedBox(height: 8),
          Text(
            'Log your first meals and sync your devices to unlock trends.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLoadDemo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Load Demo Data',
                style: AppTextStyles.label.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
