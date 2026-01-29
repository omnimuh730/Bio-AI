import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsAccountRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const SettingsAccountRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Icon(
                icon,
                size: 18,
                color: color ?? AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.textMain,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
