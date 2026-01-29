import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PlannerLeftoverPrompt extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;

  const PlannerLeftoverPrompt({
    super.key,
    required this.title,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Save Leftovers',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Did you cook the whole batch of $title?',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _promptButton(
                    'Yes, add leftovers',
                    onConfirm,
                    filled: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _promptButton(
                    'No, just this meal',
                    () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _promptButton(
    String label,
    VoidCallback onTap, {
    bool filled = false,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: filled
            ? AppColors.accentBlue
            : const Color(0xFFF1F5F9),
        foregroundColor: filled ? Colors.white : AppColors.textMain,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
