import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'planner/planner_helper.dart';
import 'planner/planner_state.dart';
import 'planner/widgets/planner_cook_view.dart';
import 'planner/widgets/planner_eat_out_view.dart';
import 'planner/widgets/planner_export_modal.dart';
import 'planner/widgets/planner_header.dart';
import 'planner/widgets/planner_leftover_prompt.dart';
import 'planner/widgets/planner_recipe_modal.dart';
import 'planner/widgets/planner_shopping_drawer.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final PlannerStateHolder _s = PlannerStateHolder();

  void _onNavTapped(int index) {
    onPlannerNavTapped(context, index);
  }

  void _onFabTapped() {
    onPlannerFabTapped(context);
  }

  void _toggleDrawer() {
    setState(() => _s.drawerExpanded = !_s.drawerExpanded);
  }

  void _switchCookTab(String tab) {
    setState(() => _s.cookTab = tab);
  }

  void _openRecipe(PlannerRecipeItem recipe) {
    _s.activeRecipe = recipe.keyId;
    showDialog(
      context: context,
      builder: (context) => PlannerRecipeModal(
        recipe: recipe,
        onCooked: _openLeftoverPrompt,
        onAddMissing: () {
          setState(() => _s.shoppingCount += 1);
          showPlannerToast(context, 'Added missing items');
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openLeftoverPrompt() {
    final recipe = _s.recipes.firstWhere(
      (item) => item.keyId == _s.activeRecipe,
    );
    showDialog(
      context: context,
      builder: (context) => PlannerLeftoverPrompt(
        title: recipe.title,
        onConfirm: () {
          final servings = recipe.batchServings;
          final left = servings > 1 ? servings - 1 : 1;
          setState(() {
            _s.leftovers.insert(
              0,
              PlannerLeftoverItem(recipe.title, left, 'Cooked today'),
            );
            _s.cookTab = 'leftovers';
          });
          Navigator.pop(context);
          Navigator.pop(context);
          showPlannerToast(context, 'Leftovers added');
        },
      ),
    );
  }

  void _logLeftover(int index) {
    setState(() {
      _s.leftovers[index].servings -= 1;
      if (_s.leftovers[index].servings <= 0) {
        _s.leftovers.removeAt(index);
      }
    });
    showPlannerToast(context, 'Leftover logged');
  }

  void _removeLeftover(int index) {
    setState(() => _s.leftovers.removeAt(index));
    showPlannerToast(context, 'Leftover removed');
  }

  void _addToShoppingList(PlannerRecipeItem recipe) {
    final alreadyAdded = _s.addedRecipes.contains(recipe.keyId);
    if (alreadyAdded) {
      showPlannerToast(context, 'Already in shopping list');
      return;
    }
    if (recipe.missing == 'Pantry Ready') {
      showPlannerToast(context, 'Already in pantry');
      return;
    }
    setState(() {
      _s.addedRecipes.add(recipe.keyId);
      _s.shoppingCount += 1;
    });
    showPlannerToast(context, 'Added to shopping list');
  }

  void _showExportModal() {
    showDialog(
      context: context,
      builder: (context) =>
          PlannerExportModal(onClose: () => Navigator.pop(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBody,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlannerHeader(
                  cookView: _s.cookView,
                  onCook: () => setState(() => _s.cookView = true),
                  onEatOut: () => setState(() => _s.cookView = false),
                ),
                _s.cookView
                    ? PlannerCookView(
                        cookTab: _s.cookTab,
                        onTabChanged: _switchCookTab,
                        pantryTags: _s.pantryTags,
                        recipes: _s.recipes,
                        leftovers: _s.leftovers,
                        addedRecipeIds: _s.addedRecipes,
                        onOpenRecipe: _openRecipe,
                        onAddToShop: _addToShoppingList,
                        onLogLeftover: _logLeftover,
                        onRemoveLeftover: _removeLeftover,
                      )
                    : const PlannerEatOutView(),
                const SizedBox(height: 160),
              ],
            ),
          ),
          PlannerShoppingDrawer(
            expanded: _s.drawerExpanded,
            onToggle: _toggleDrawer,
            shoppingCount: _s.shoppingCount,
            onExport: _showExportModal,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingNavBar(
                selectedIndex: 1,
                onItemTapped: _onNavTapped,
                onFabTapped: _onFabTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
