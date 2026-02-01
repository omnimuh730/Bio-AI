class PlannerLeftoverItem {
  final String title;
  int servings;
  final String note;

  PlannerLeftoverItem(this.title, this.servings, this.note);
}

class PlannerRecipeItem {
  final String keyId;
  final String title;
  final String minutes;
  final String calories;
  final String missing;
  final String image;
  final String meta;
  final String ingredients;
  final String steps;
  final int batchServings;

  const PlannerRecipeItem({
    required this.keyId,
    required this.title,
    required this.minutes,
    required this.calories,
    required this.missing,
    required this.image,
    required this.meta,
    required this.ingredients,
    required this.steps,
    required this.batchServings,
  });
}

class PlannerStateHolder {
  bool cookView = true;
  String cookTab = 'pantry';
  bool drawerExpanded = false;
  int shoppingCount = 3;
  String? activeRecipe;
  final Set<String> addedRecipes = {};

  final List<String> pantryTags = ['Chicken Breast', 'Spinach', 'Rice'];
  final List<PlannerRecipeItem> recipes = const [
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

  final List<PlannerLeftoverItem> leftovers = [
    PlannerLeftoverItem('Power Chicken Bowl', 3, 'Cooked today'),
    PlannerLeftoverItem('Green Keto Salad', 1, 'Cooked yesterday'),
  ];
}
