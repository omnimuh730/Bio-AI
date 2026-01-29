import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsGoalOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SettingsGoalOption({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.accentBlue : const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0x0D4B7BFF) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.accentBlue
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: AppColors.accentBlue,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
