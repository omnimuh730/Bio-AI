import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';

class AnalyticsHistoryEntry {
  final String hour;
  final String meridiem;
  final String title;
  final String subtitle;
  final String value;
  final Color valueColor;

  const AnalyticsHistoryEntry(
    this.hour,
    this.meridiem,
    this.title,
    this.subtitle,
    this.value,
    this.valueColor,
  );
}

class AnalyticsData {
  static const Map<String, String> metricLabels = {
    'calories': 'Calorie Intake',
    'protein': 'Protein Intake',
    'carbs': 'Carb Intake',
    'active': 'Active Burn',
    'hydration': 'Hydration',
    'sleep': 'Sleep Quality',
    'energy': 'Energy Score',
    'hrv': 'HRV / Stress',
    'steps': 'Steps',
    'mood': 'Mood',
  };

  static const Map<String, List<String>> xAxis = {
    'W': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'M': ['Wk1', 'Wk2', 'Wk3', 'Wk4'],
    '3M': ['Jan', 'Feb', 'Mar'],
  };

  static const Map<String, Map<String, List<double>>> chartData = {
    'W': {
      'calories': [1800, 1950, 2100, 1700, 2250, 2050, 1900],
      'protein': [110, 125, 118, 98, 135, 122, 114],
      'carbs': [210, 190, 240, 160, 260, 215, 200],
      'active': [480, 520, 610, 390, 720, 540, 500],
      'hydration': [1600, 1800, 1400, 2100, 1900, 1750, 2000],
      'sleep': [68, 74, 70, 62, 78, 72, 75],
      'energy': [76, 80, 78, 70, 85, 82, 79],
      'hrv': [32, 34, 29, 26, 38, 35, 33],
      'steps': [6800, 7200, 9100, 5300, 10400, 8400, 7600],
      'mood': [6, 7, 6, 5, 8, 7, 7],
    },
    'M': {
      'calories': [18800, 19600, 18200, 20100],
      'protein': [780, 840, 790, 860],
      'carbs': [1380, 1460, 1320, 1500],
      'active': [3500, 4100, 3700, 4300],
      'hydration': [11800, 12300, 11500, 12900],
      'sleep': [71, 74, 69, 76],
      'energy': [78, 82, 76, 84],
      'hrv': [31, 34, 28, 36],
      'steps': [52000, 56800, 49000, 60200],
      'mood': [6.5, 7.2, 6.4, 7.5],
    },
    '3M': {
      'calories': [76500, 78200, 80100],
      'protein': [3280, 3420, 3580],
      'carbs': [5900, 6040, 6210],
      'active': [15200, 16750, 17400],
      'hydration': [46800, 48200, 50100],
      'sleep': [70, 72, 75],
      'energy': [77, 80, 83],
      'hrv': [30, 33, 35],
      'steps': [210000, 224000, 236000],
      'mood': [6.7, 7.1, 7.4],
    },
  };

  static const Map<String, List<double>> fallbackSeries = {
    'W': [1800, 2000, 1900, 2100, 2050, 2200, 1950],
    'M': [18600, 19400, 18800, 20100],
    '3M': [76000, 78200, 79900],
  };

  static const List<AnalyticsHistoryEntry> mockHistory = [
    AnalyticsHistoryEntry(
      '12',
      'PM',
      'Magnesium Power Bowl',
      'Quinoa, Avocado, Kale',
      '450',
      AppColors.textMain,
    ),
    AnalyticsHistoryEntry(
      '08',
      'AM',
      'Oatmeal & Berries',
      'Rolled oats, Blueberry',
      '320',
      AppColors.textMain,
    ),
    AnalyticsHistoryEntry(
      '03',
      'PM',
      'Protein Smoothie',
      'Whey, Banana, Almond Milk',
      '260',
      AppColors.textMain,
    ),
    AnalyticsHistoryEntry(
      '07',
      'AM',
      'Morning Run',
      'Active Burn',
      '-240',
      AppColors.accentGreen,
    ),
    AnalyticsHistoryEntry(
      '06',
      'AM',
      'Hydration',
      'Water intake',
      '+500ml',
      AppColors.textMain,
    ),
    AnalyticsHistoryEntry(
      '06',
      'AM',
      'Sleep Summary',
      '7h 25m, Restorative',
      '74',
      AppColors.textMain,
    ),
  ];

  static List<double> seriesFor(String range, String metric) {
    final series = chartData[range]?[metric] ?? const [];
    if (series.isNotEmpty) {
      return series;
    }
    return fallbackSeries[range] ?? const [0, 1];
  }
}
