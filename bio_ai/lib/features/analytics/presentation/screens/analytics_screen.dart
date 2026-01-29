import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:bio_ai/features/vision/presentation/screens/capture_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:bio_ai/ui/pages/analytics/models/analytics_history_entry.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_correlations_card.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_empty_state.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_header.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_history_edit_modal.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_history_section.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_score_card.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_summary_grid.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_weekly_review.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _range = 'W';
  String _metricA = 'calories';
  String _metricB = 'sleep';
  bool _hasData = true;

  final Map<String, String> _metricLabels = const {
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

  final Map<String, List<String>> _xAxis = const {
    'W': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'M': ['Wk1', 'Wk2', 'Wk3', 'Wk4'],
    '3M': ['Jan', 'Feb', 'Mar'],
  };

  final Map<String, Map<String, List<double>>> _chartData = const {
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
      'sleep': [69, 71, 70],
      'energy': [80, 82, 79],
      'hrv': [30, 33, 29],
      'steps': [150000, 160000, 152000],
      'mood': [6.8, 7.1, 6.9],
    },
  };

  final List<AnalyticsHistoryEntry> _history = const [
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
                const AnalyticsHeader(),
                const SizedBox(height: 8),
                AnalyticsScoreCard(),
                AnalyticsSummaryGrid(),
                AnalyticsCorrelationsCard(
                  range: _range,
                  onRangeChanged: (r) => setState(() => _range = r),
                  metricA: _metricA,
                  metricB: _metricB,
                  metricLabels: _metricLabels,
                  onMetricAChanged: (m) => setState(() => _metricA = m),
                  onMetricBChanged: (m) => setState(() => _metricB = m),
                  primary: _chartData[_range]?[_metricA] ?? [],
                  secondary: _chartData[_range]?[_metricB] ?? [],
                  labels: _xAxis[_range] ?? [],
                ),
                AnalyticsHistorySection(history: _history, onEdit: (entry) {}),
                AnalyticsWeeklyReview(),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingNavBar(
                selectedIndex: 2,
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
                  if (index == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlannerScreen(),
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
}
