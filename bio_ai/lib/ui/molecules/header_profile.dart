import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class HeaderProfile extends StatelessWidget {
  const HeaderProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.kAccentGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.kAccentGreen.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2)
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Bio-Sync Active',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.kTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Hello, Dekomori',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kTextMain,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.kAccentBlue),
          ),
        ],
      ),
    );
  }
}