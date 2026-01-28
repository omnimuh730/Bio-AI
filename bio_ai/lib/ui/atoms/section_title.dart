import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;
  final String? linkText;

  const SectionTitle(this.title, {super.key, this.onRefresh, this.linkText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextMain,
            ),
          ),
          if (onRefresh != null || linkText != null)
            GestureDetector(
              onTap: onRefresh,
              child: Text(
                linkText ?? 'Refresh',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.kAccentBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}