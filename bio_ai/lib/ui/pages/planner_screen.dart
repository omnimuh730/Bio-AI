import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/vision/presentation/screens/capture_screen.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'planner/models/planner_leftover_item.dart';
import 'planner/models/planner_recipe_item.dart';
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
  bool _cookView = true;
  String _cookTab = 'pantry';
  bool _drawerExpanded = false;
  int _shoppingCount = 3;
  String? _activeRecipe;
  final Set<String> _addedRecipes = {};

  final List<String> _pantryTags = ['Chicken Breast', 'Spinach', 'Rice'];
  final List<PlannerRecipeItem> _recipes = const [
    PlannerRecipeItem(
      keyId: 'power',
      title: 'Power Chicken Bowl',
      minutes: '20m',
      calories: '520 kcal',
      missing: 'Missing: Lemon',
      image:
          'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=150&q=80',
      meta: '20 min - 520 kcal',
      ingredients: 'Chicken breast, spinach, rice, lemon, olive oil',
      steps:
          'Sear chicken, steam rice, saute spinach, finish with lemon and olive oil.',
      batchServings: 4,
    ),
    PlannerRecipeItem(
      keyId: 'keto',
      title: 'Green Keto Salad',
      minutes: '10m',
      calories: '340 kcal',
      missing: 'Pantry Ready',
      image:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=150&q=80',
      meta: '10 min - 340 kcal',
      ingredients: 'Kale, avocado, cucumber, olive oil, pumpkin seeds',
      steps:
          'Chop greens, toss with avocado and cucumber, dress with olive oil, top seeds.',
      batchServings: 2,
    ),
  ];

  final List<PlannerLeftoverItem> _leftovers = [
    PlannerLeftoverItem('Power Chicken Bowl', 3, 'Cooked today'),
    PlannerLeftoverItem('Green Keto Salad', 1, 'Cooked yesterday'),
  ];

  void _onNavTapped(int index) {
    if (index == 1) {
      return;
    }
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
      );
      return;
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }

  void _onFabTapped() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CaptureScreen()),
    );
  }

  void _toggleDrawer() {
    setState(() => _drawerExpanded = !_drawerExpanded);
  }

  void _switchCookTab(String tab) {
    setState(() => _cookTab = tab);
  }

  void _openRecipe(PlannerRecipeItem recipe) {
    _activeRecipe = recipe.keyId;
    showDialog(
      context: context,
      builder: (context) => PlannerRecipeModal(
        recipe: recipe,
        onCooked: _openLeftoverPrompt,
        onAddMissing: () {
          setState(() => _shoppingCount += 1);
          _showToast('Added missing items');
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openLeftoverPrompt() {
    final recipe = _recipes.firstWhere((item) => item.keyId == _activeRecipe);
    showDialog(
      context: context,
      builder: (context) => PlannerLeftoverPrompt(
        title: recipe.title,
        onConfirm: () {
          final servings = recipe.batchServings;
          final left = servings > 1 ? servings - 1 : 1;
          setState(() {
            _leftovers.insert(
              0,
              PlannerLeftoverItem(recipe.title, left, 'Cooked today'),
            );
            _cookTab = 'leftovers';
          });
          Navigator.pop(context);
          Navigator.pop(context);
          _showToast('Leftovers added');
        },
      ),
    );
  }

  void _logLeftover(int index) {
    setState(() {
      _leftovers[index].servings -= 1;
      if (_leftovers[index].servings <= 0) {
        _leftovers.removeAt(index);
      }
    });
    _showToast('Leftover logged');
  }

  void _removeLeftover(int index) {
    setState(() => _leftovers.removeAt(index));
    _showToast('Leftover removed');
  }

  void _addToShoppingList(PlannerRecipeItem recipe) {
    final alreadyAdded = _addedRecipes.contains(recipe.keyId);
    if (alreadyAdded) {
      _showToast('Already in shopping list');
      return;
    }
    if (recipe.missing == 'Pantry Ready') {
      _showToast('Already in pantry');
      return;
    }
    setState(() {
      _addedRecipes.add(recipe.keyId);
      _shoppingCount += 1;
    });
    _showToast('Added to shopping list');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
      ),
    );
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
                  cookView: _cookView,
                  onCook: () => setState(() => _cookView = true),
                  onEatOut: () => setState(() => _cookView = false),
                ),
                _cookView
                    ? PlannerCookView(
                        cookTab: _cookTab,
                        onTabChanged: _switchCookTab,
                        pantryTags: _pantryTags,
                        recipes: _recipes,
                        leftovers: _leftovers,
                        addedRecipeIds: _addedRecipes,
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
            expanded: _drawerExpanded,
            onToggle: _toggleDrawer,
            shoppingCount: _shoppingCount,
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
