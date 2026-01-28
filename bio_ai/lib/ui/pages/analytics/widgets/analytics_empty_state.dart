import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
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
            child: const Icon(
              Icons.eco,
              color: AppColors.kAccentBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gathering your bio-data...',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your first meals and sync your devices to unlock trends.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.kTextSecondary,
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
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }
}
