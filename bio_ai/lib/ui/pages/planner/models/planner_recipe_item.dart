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
