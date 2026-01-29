import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';

class AnalyticsHeader extends StatelessWidget {
  const AnalyticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Analysis',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            size: 20,
            color: AppColors.textMain,
          ),
        ],
      ),
    );
  }
}
