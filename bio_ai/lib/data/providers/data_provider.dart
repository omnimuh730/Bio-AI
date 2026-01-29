import 'package:flutter/material.dart';
import './../models//data_models.dart';

/// Central data provider for the application.
/// This class manages all application state and provides it to UI components.
/// Use it as: DataProvider provider = Provider.of<DataProvider>(context);
class DataProvider extends ChangeNotifier {
  // User Data
  late UserProfile _userProfile;
  late DailyGoals _dailyGoals;

  // Health Data
  late HealthMetrics _todayMetrics;
  final List<HealthMetrics> _metricsHistory = [];

  // Meal Data
  final List<MealData> _todayMeals = [];
  final List<MealData> _mealHistory = [];

  // UI State
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile get userProfile => _userProfile;
  DailyGoals get dailyGoals => _dailyGoals;
  HealthMetrics get todayMetrics => _todayMetrics;
  List<HealthMetrics> get metricsHistory => _metricsHistory;
  List<MealData> get todayMeals => _todayMeals;
  List<MealData> get mealHistory => _mealHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DataProvider() {
    _initializeWithMockData();
  }

  /// Initialize with mock data (for development)
  void _initializeWithMockData() {
    _userProfile = UserProfile.mock();
    _dailyGoals = DailyGoals.default_();
    _todayMetrics = HealthMetrics.mock();
  }

  // ==================== User Profile Methods ====================

  /// Update user profile
  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  // ==================== Daily Goals Methods ====================

  /// Update daily goals
  void updateDailyGoals(DailyGoals goals) {
    _dailyGoals = goals;
    notifyListeners();
  }

  // ==================== Health Metrics Methods ====================

  /// Update today's health metrics
  void updateTodayMetrics(HealthMetrics metrics) {
    _todayMetrics = metrics;
    notifyListeners();
  }

  /// Add metrics to history
  void addMetricsToHistory(HealthMetrics metrics) {
    _metricsHistory.add(metrics);
    notifyListeners();
  }

  /// Get metrics for a specific date
  HealthMetrics? getMetricsForDate(DateTime date) {
    try {
      return _metricsHistory.firstWhere((m) => _isSameDay(m, date));
    } catch (e) {
      return null;
    }
  }

  /// Get metrics for the past N days
  List<HealthMetrics> getMetricsForPastDays(int days) {
    final now = DateTime.now();
    return _metricsHistory.where((m) {
      final difference = now.difference(m.createdAt).inDays;
      return difference <= days;
    }).toList();
  }

  // ==================== Meal Methods ====================

  /// Add meal to today's meals
  void addMealToToday(MealData meal) {
    _todayMeals.add(meal);
    // Update health metrics with new calorie count
    _todayMetrics = _todayMetrics.copyWith(
      calories: _todayMetrics.calories + meal.calories,
      protein: _todayMetrics.protein + meal.protein,
      carbs: _todayMetrics.carbs + meal.carbs,
      fat: _todayMetrics.fat + meal.fat,
    );
    notifyListeners();
  }

  /// Remove meal from today's meals
  void removeMealFromToday(String mealId) {
    final meal = _todayMeals.firstWhere((m) => m.id == mealId);
    _todayMeals.removeWhere((m) => m.id == mealId);

    // Update health metrics
    _todayMetrics = _todayMetrics.copyWith(
      calories: _todayMetrics.calories - meal.calories,
      protein: _todayMetrics.protein - meal.protein,
      carbs: _todayMetrics.carbs - meal.carbs,
      fat: _todayMetrics.fat - meal.fat,
    );
    notifyListeners();
  }

  /// Add meal to history
  void addMealToHistory(MealData meal) {
    _mealHistory.add(meal);
    notifyListeners();
  }

  /// Get meals for a specific date
  List<MealData> getMealsForDate(DateTime date) {
    return _mealHistory
        .where((meal) => _isSameDay(meal.timestamp, date))
        .toList();
  }

  // ==================== Loading & Error State ====================

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== Helper Methods ====================

  bool _isSameDay(dynamic data, DateTime date) {
    DateTime dataDate;
    if (data is HealthMetrics) {
      dataDate = data.createdAt;
    } else if (data is DateTime) {
      dataDate = data;
    } else {
      return false;
    }

    return dataDate.year == date.year &&
        dataDate.month == date.month &&
        dataDate.day == date.day;
  }
}
