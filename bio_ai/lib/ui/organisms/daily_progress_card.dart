import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../molecules/macro_row.dart';

class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Circular Ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: 0.65,
                    strokeWidth: 6,
                    backgroundColor: Color(0xFFF1F5F9),
                    color: AppColors.kAccentBlue,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '1,240',
                      style: GoogleFonts.dmSans(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'LEFT',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.kTextSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Macros
          const Expanded(
            child: Column(
              children: [
                MacroRow(
                    label: 'Protein',
                    val: '80g / 140g',
                    pct: 0.6,
                    color: AppColors.kAccentPurple),
                SizedBox(height: 12),
                MacroRow(
                    label: 'Carbs',
                    val: '120g / 200g',
                    pct: 0.8,
                    color: AppColors.kAccentGreen),
                SizedBox(height: 12),
                MacroRow(
                    label: 'Fat',
                    val: '30g / 70g',
                    pct: 0.4,
                    color: AppColors.kAccentOrange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}