import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/planner_recipe_item.dart';

class PlannerRecipeModal extends StatelessWidget {
  final PlannerRecipeItem recipe;
  final VoidCallback onCooked;
  final VoidCallback onAddMissing;

  const PlannerRecipeModal({
    super.key,
    required this.recipe,
    required this.onCooked,
    required this.onAddMissing,
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
                  recipe.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kTextMain,
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
            const SizedBox(height: 8),
            Text(
              recipe.meta,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.kTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ingredients',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              recipe.ingredients,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.steps,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.4,
                color: AppColors.kTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _modalButton('Cooked This', onCooked, filled: true),
                _modalButton('Add Missing to List', onAddMissing),
                _modalButton('Close', () => Navigator.pop(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modalButton(String label, VoidCallback onTap, {bool filled = false}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: filled
            ? AppColors.accentBlue
            : const Color(0xFFF1F5F9),
        foregroundColor: filled ? Colors.white : AppColors.textMain,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
