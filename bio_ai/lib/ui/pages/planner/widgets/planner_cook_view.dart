import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/planner_leftover_item.dart';
import '../models/planner_recipe_item.dart';
import 'planner_leftover_card.dart';
import 'planner_pantry_box.dart';
import 'planner_recipe_card.dart';
import 'planner_sub_tabs.dart';

class PlannerCookView extends StatelessWidget {
  final String cookTab;
  final ValueChanged<String> onTabChanged;
  final List<String> pantryTags;
  final List<PlannerRecipeItem> recipes;
  final List<PlannerLeftoverItem> leftovers;
  final Set<String> addedRecipeIds;
  final ValueChanged<PlannerRecipeItem> onOpenRecipe;
  final ValueChanged<PlannerRecipeItem> onAddToShop;
  final ValueChanged<int> onLogLeftover;
  final ValueChanged<int> onRemoveLeftover;

  const PlannerCookView({
    super.key,
    required this.cookTab,
    required this.onTabChanged,
    required this.pantryTags,
    required this.recipes,
    required this.leftovers,
    required this.addedRecipeIds,
    required this.onOpenRecipe,
    required this.onAddToShop,
    required this.onLogLeftover,
    required this.onRemoveLeftover,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlannerSubTabs(cookTab: cookTab, onTabChanged: onTabChanged),
          const SizedBox(height: 16),
          if (cookTab == 'pantry') ...[
            PlannerPantryBox(pantryTags: pantryTags),
            const SizedBox(height: 24),
            Text(
              'Matched Recipes',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ...recipes.map(
              (recipe) => PlannerRecipeCard(
                recipe: recipe,
                onOpen: () => onOpenRecipe(recipe),
                onAddToShop: () => onAddToShop(recipe),
                addedToShop: addedRecipeIds.contains(recipe.keyId),
              ),
            ),
          ] else ...[
            Text(
              'Leftovers',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            if (leftovers.isEmpty)
              Text(
                'No leftovers yet. Cook a batch to save servings here.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ...leftovers.asMap().entries.map(
              (entry) => PlannerLeftoverCard(
                item: entry.value,
                onLog: () => onLogLeftover(entry.key),
                onRemove: () => onRemoveLeftover(entry.key),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
