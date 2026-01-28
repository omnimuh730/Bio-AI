import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/planner_recipe_item.dart';

class PlannerRecipeCard extends StatelessWidget {
  final PlannerRecipeItem recipe;
  final VoidCallback onOpen;
  final VoidCallback onAddToShop;
  final bool addedToShop;

  const PlannerRecipeCard({
    super.key,
    required this.recipe,
    required this.onOpen,
    required this.onAddToShop,
    required this.addedToShop,
  });

  @override
  Widget build(BuildContext context) {
    final isMissing = recipe.missing != 'Pantry Ready';
    final isChecked = addedToShop || !isMissing;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              recipe.image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kTextMain,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: AppColors.kTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.minutes,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.kTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: AppColors.kTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.calories,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.kTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isMissing ? const Color(0x1AF59E0B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    recipe.missing,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isMissing
                          ? const Color(0xFFF59E0B)
                          : AppColors.kTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onOpen,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View Recipe',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAddToShop,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isChecked ? Icons.check : Icons.shopping_cart,
                size: 16,
                color: isChecked ? AppColors.kAccentGreen : AppColors.kTextMain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
