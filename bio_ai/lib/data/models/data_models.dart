// Data Models for centralized management
class HealthMetrics {
  final int calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final int water; // in ml
  final int steps;
  final int heartRate; // bpm
  final double sleepScore; // 0-100
  final double stressLevel; // 0-100
  final double hrvScore; // Heart Rate Variability
  final DateTime createdAt;

  HealthMetrics({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.water,
    required this.steps,
    required this.heartRate,
    required this.sleepScore,
    required this.stressLevel,
    required this.hrvScore,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Factory constructor for mock data
  factory HealthMetrics.mock() {
    return HealthMetrics(
      calories: 1850,
      protein: 85,
      carbs: 220,
      fat: 65,
      water: 1500,
      steps: 7234,
      heartRate: 72,
      sleepScore: 78.5,
      stressLevel: 35.2,
      hrvScore: 42.5,
    );
  }

  HealthMetrics copyWith({
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    int? water,
    int? steps,
    int? heartRate,
    double? sleepScore,
    double? stressLevel,
    double? hrvScore,
    DateTime? createdAt,
  }) {
    return HealthMetrics(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      water: water ?? this.water,
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      sleepScore: sleepScore ?? this.sleepScore,
      stressLevel: stressLevel ?? this.stressLevel,
      hrvScore: hrvScore ?? this.hrvScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MealData {
  final String id;
  final String name;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime timestamp;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? imageUrl;
  final String? reason; // Why this meal was suggested
  final String? badge; // Badge text (Anti-Stress, Energy Boost, etc.)

  MealData({
    required this.id,
    required this.name,
    required this.mealType,
    required this.timestamp,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl,
    this.reason,
    this.badge,
  });

  MealData copyWith({
    String? id,
    String? name,
    String? mealType,
    DateTime? timestamp,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? imageUrl,
    String? reason,
    String? badge,
  }) {
    return MealData(
      id: id ?? this.id,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      timestamp: timestamp ?? this.timestamp,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      imageUrl: imageUrl ?? this.imageUrl,
      reason: reason ?? this.reason,
      badge: badge ?? this.badge,
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String? profileImageUrl;
  final int age;
  final String gender; // male, female, other
  final double height; // in cm
  final double weight; // in kg
  final List<String> dietaryPreferences; // gluten-free, vegan, etc.

  UserProfile({
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.dietaryPreferences,
  });

  factory UserProfile.mock() {
    return UserProfile(
      name: 'Dekomori',
      email: 'dekomori@example.com',
      age: 28,
      gender: 'female',
      height: 165,
      weight: 62,
      dietaryPreferences: [],
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? profileImageUrl,
    int? age,
    String? gender,
    double? height,
    double? weight,
    List<String>? dietaryPreferences,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    );
  }
}

class DailyGoals {
  final int caloriesTarget;
  final double proteinTarget; // in grams
  final double carbsTarget; // in grams
  final double fatTarget; // in grams
  final int waterTarget; // in ml
  final int stepsTarget;
  final double sleepTarget; // in hours

  DailyGoals({
    required this.caloriesTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.waterTarget,
    required this.stepsTarget,
    required this.sleepTarget,
  });

  factory DailyGoals.default_() {
    return DailyGoals(
      caloriesTarget: 2000,
      proteinTarget: 100,
      carbsTarget: 250,
      fatTarget: 65,
      waterTarget: 2000,
      stepsTarget: 10000,
      sleepTarget: 8,
    );
  }

  DailyGoals copyWith({
    int? caloriesTarget,
    double? proteinTarget,
    double? carbsTarget,
    double? fatTarget,
    int? waterTarget,
    int? stepsTarget,
    double? sleepTarget,
  }) {
    return DailyGoals(
      caloriesTarget: caloriesTarget ?? this.caloriesTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      waterTarget: waterTarget ?? this.waterTarget,
      stepsTarget: stepsTarget ?? this.stepsTarget,
      sleepTarget: sleepTarget ?? this.sleepTarget,
    );
  }

  double get caloriesProgress => 1850 / caloriesTarget;
  double get proteinProgress => 85 / proteinTarget;
  double get carbsProgress => 220 / carbsTarget;
  double get fatProgress => 65 / fatTarget;
  double get waterProgress => 1500 / waterTarget;
  double get stepsProgress => 7234 / stepsTarget;
}
