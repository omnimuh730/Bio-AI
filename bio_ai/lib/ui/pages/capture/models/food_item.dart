class FoodItem {
  final String name;
  final String desc;
  final double cals;
  final double protein;
  final double fat;
  final String image;
  final String? impact;
  final Map<String, dynamic>? metadata; // holds raw API data or extra info
  int portionIndex;

  FoodItem({
    required this.name,
    required this.desc,
    required this.cals,
    required this.protein,
    required this.fat,
    required this.image,
    this.impact,
    this.metadata,
    this.portionIndex = 1,
  });
}
