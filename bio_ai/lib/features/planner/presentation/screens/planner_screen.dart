import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/vision/presentation/screens/capture_screen.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:bio_ai/ui/pages/planner/models/planner_leftover_item.dart';
import 'package:bio_ai/ui/pages/planner/models/planner_recipe_item.dart';
import 'package:bio_ai/ui/pages/planner/widgets/planner_cook_view.dart';
import 'package:bio_ai/ui/pages/planner/widgets/planner_eat_out_view.dart';
import 'package:bio_ai/ui/pages/planner/widgets/planner_export_modal.dart';
import 'package:bio_ai/ui/pages/planner/widgets/planner_header.dart';
import 'package:bio_ai/ui/pages/planner/widgets/planner_leftover_prompt.dart';
import 'package:bio_ai/ui/pages/planner/widgets/planner_recipe_modal.dart';
import 'package:bio_ai/ui/pages/planner/widgets/planner_shopping_drawer.dart';

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
      batchServings: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBody,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlannerHeader(
                  shoppingCount: _shoppingCount,
                  onOpenDrawer: () => setState(() => _drawerExpanded = true),
                ),
                if (_cookView)
                  PlannerCookView(
                    cookTab: _cookTab,
                    onTabChanged: (tab) => setState(() => _cookTab = tab),
                    pantryTags: _pantryTags,
                    recipes: _recipes,
                    leftovers: const [],
                    addedRecipeIds: _addedRecipes,
                    onOpenRecipe: (r) =>
                        setState(() => _activeRecipe = r.keyId),
                    onAddToShop: (r) =>
                        setState(() => _addedRecipes.add(r.keyId)),
                    onLogLeftover: (idx) => _showToast('Logged leftover #$idx'),
                    onRemoveLeftover: (idx) =>
                        _showToast('Removed leftover #$idx'),
                  )
                else
                  PlannerEatOutView(),
                PlannerLeftoverPrompt(
                  onUseLeftover: (name) {
                    setState(() {
                      _addedRecipes.add(name);
                      _showToast('Added $name from leftovers');
                    });
                  },
                ),
              ],
            ),
          ),
          if (_drawerExpanded)
            PlannerShoppingDrawer(
              expanded: _drawerExpanded,
              onToggle: () =>
                  setState(() => _drawerExpanded = !_drawerExpanded),
              shoppingCount: _shoppingCount,
              onExport: () => _showToast('Export shopping list'),
            ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingNavBar(
                selectedIndex: 1,
                onItemTapped: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                    return;
                  }
                  if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    );
                    return;
                  }
                  if (index == 3) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                    return;
                  }
                },
                onFabTapped: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CaptureScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
