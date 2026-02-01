import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'planner/planner_helper.dart';
import 'planner/planner_state.dart';

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

class PlannerHeader extends StatelessWidget {
  final bool cookView;
  final VoidCallback onCook;
  final VoidCallback onEatOut;

  const PlannerHeader({
    super.key,
    required this.cookView,
    required this.onCook,
    required this.onEatOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Smart Planner', style: AppTextStyles.heading1),
              const Icon(
                Icons.calendar_month,
                size: 20,
                color: AppColors.accentBlue,
              ),
            ],
          ),
          const SizedBox(height: 20),
          PlannerViewToggle(
            cookView: cookView,
            onCook: onCook,
            onEatOut: onEatOut,
          ),
        ],
      ),
    );
  }
}

class PlannerViewToggle extends StatelessWidget {
  final bool cookView;
  final VoidCallback onCook;
  final VoidCallback onEatOut;

  const PlannerViewToggle({
    super.key,
    required this.cookView,
    required this.onCook,
    required this.onEatOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                left: cookView ? 0 : width / 2,
                top: 0,
                bottom: 0,
                child: Container(
                  width: width / 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _toggleOption('Cook at Home', cookView, onCook),
                  _toggleOption('Eat Out', !cookView, onEatOut),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toggleOption(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: active ? AppColors.accentBlue : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

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
              style: AppTextStyles.labelSmall.copyWith(
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
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            if (leftovers.isEmpty)
              Text(
                'No leftovers yet. Cook a batch to save servings here.',
                style: AppTextStyles.labelSmall.copyWith(
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

class PlannerSubTabs extends StatelessWidget {
  final String cookTab;
  final ValueChanged<String> onTabChanged;

  const PlannerSubTabs({
    super.key,
    required this.cookTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _subTab('Pantry', cookTab == 'pantry', () => onTabChanged('pantry')),
          _subTab(
            'Leftovers',
            cookTab == 'leftovers',
            () => onTabChanged('leftovers'),
          ),
        ],
      ),
    );
  }

  Widget _subTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: active ? AppColors.textMain : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class PlannerPantryBox extends StatelessWidget {
  final List<String> pantryTags;

  const PlannerPantryBox({super.key, required this.pantryTags});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Pantry',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add ingredients (e.g. Avocado)...',
                    hintStyle: AppTextStyles.labelSmall,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pantryTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.close,
                          size: 12,
                          color: AppColors.accentBlue,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                Text(recipe.title, style: AppTextStyles.dmSans16Bold),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.minutes,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.calories,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isMissing
                        ? const Color(0x1AF59E0B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    recipe.missing,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isMissing
                          ? const Color(0xFFF59E0B)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onOpen,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View Recipe',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
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
                color: isChecked ? AppColors.accentGreen : AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlannerLeftoverCard extends StatelessWidget {
  final PlannerLeftoverItem item;
  final VoidCallback onLog;
  final VoidCallback onRemove;

  const PlannerLeftoverCard({
    super.key,
    required this.item,
    required this.onLog,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.servings} servings - ${item.note}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _leftoverButton('Log', onLog, primary: true),
              const SizedBox(width: 6),
              _leftoverButton('Remove', onRemove),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leftoverButton(
    String label,
    VoidCallback onTap, {
    bool primary = false,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: primary
            ? const Color(0xFFEEF2FF)
            : const Color(0xFFF8FAFC),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: primary ? AppColors.accentBlue : AppColors.textSecondary,
        ),
      ),
    );
  }
}

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
                  style: AppTextStyles.dmSans14SemiBold.copyWith(
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
              style: AppTextStyles.labelSmall.copyWith(
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
        style: AppTextStyles.labelSmall.copyWith(
          color: filled ? Colors.white : AppColors.textMain,
        ),
      ),
    );
  }
}

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
                Text(recipe.title, style: AppTextStyles.heading3),
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
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ingredients',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              recipe.ingredients,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.steps,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
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
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class PlannerEatOutView extends StatefulWidget {
  const PlannerEatOutView({super.key});

  @override
  State<PlannerEatOutView> createState() => _PlannerEatOutViewState();
}

class _PlannerEatOutViewState extends State<PlannerEatOutView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x1A10B981),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                Text(
                  'Near 5th Avenue, NYC',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              hintText: 'Search menu (e.g. Starbucks)',
              hintStyle: AppTextStyles.labelSmall,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Menu Coach',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          PlannerMenuCard(
            brandColor: const Color(0xFF00704A),
            brand: 'Starbucks',
            title: 'Spinach, Feta & Cage-Free Egg Wrap',
            desc:
                'High protein, moderate carbs. Fits perfectly into your remaining post-workout macros.',
            calories: '290 kcal - 19g Protein',
            match: '98% Match',
            best: true,
            selected: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          const SizedBox(height: 16),
          PlannerMenuCard(
            brandColor: const Color(0xFFA52A2A),
            brand: 'Chipotle',
            title: 'Lifestyle Bowl (Paleo)',
            desc:
                'Good choice, but ask for light dressing to stay under your fat limit.',
            calories: '500 kcal - 42g Protein',
            match: '85% Match',
            selected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ],
      ),
    );
  }
}

class PlannerMenuCard extends StatelessWidget {
  final Color brandColor;
  final String brand;
  final String title;
  final String desc;
  final String calories;
  final String match;
  final bool best;
  final bool selected;
  final VoidCallback onTap;

  const PlannerMenuCard({
    super.key,
    required this.brandColor,
    required this.brand,
    required this.title,
    required this.desc,
    required this.calories,
    required this.match,
    this.best = false,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.accentBlue
        : (best ? AppColors.accentGreen : Colors.transparent);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8FAFF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: best
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (best)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    match,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    match,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMain,
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: brandColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      brand,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    calories,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlannerShoppingDrawer extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final int shoppingCount;
  final VoidCallback onExport;

  const PlannerShoppingDrawer({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.shoppingCount,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    const drawerHeight = 360.0;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      left: 0,
      right: 0,
      bottom: expanded ? 0 : -(drawerHeight - 60),
      height: drawerHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Shopping List',
                              style: AppTextStyles.dmSans16Bold,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$shoppingCount',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  const PlannerShopItem('Lemons (2)', false),
                  const PlannerShopItem('Greek Yogurt', true),
                  const PlannerShopItem('Almonds', false),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onExport,
                    icon: const Icon(Icons.shopping_basket),
                    label: const Text('Order or Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlannerShopItem extends StatefulWidget {
  final String label;
  final bool checked;

  const PlannerShopItem(this.label, this.checked, {super.key});

  @override
  State<PlannerShopItem> createState() => _PlannerShopItemState();
}

class _PlannerShopItemState extends State<PlannerShopItem> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF8FAFC))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _checked = !_checked),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _checked ? AppColors.accentBlue : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
              ),
              child: _checked
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 14,
                color: _checked ? const Color(0xFFCBD5E1) : AppColors.textMain,
                decoration: _checked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlannerExportModal extends StatelessWidget {
  final VoidCallback onClose;

  const PlannerExportModal({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final options = [
      'Amazon Fresh',
      'Instacart',
      'Walmart Grocery',
      'Kroger',
      'Copy List',
    ];
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
                  'Export Shopping List',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                InkWell(
                  onTap: onClose,
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
              'Choose a service to order or export your list.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (opt) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      opt,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      opt == 'Copy List' ? 'Clipboard' : 'Order',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: AppColors.textMain,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Close',
                style: AppTextStyles.label.copyWith(color: AppColors.textMain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
