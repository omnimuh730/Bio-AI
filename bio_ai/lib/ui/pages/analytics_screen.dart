import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../organisms/floating_nav_bar.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'capture_screen.dart';
import 'planner_screen.dart';
import 'analytics/models/analytics_history_entry.dart';
import 'analytics/widgets/analytics_correlations_card.dart';
import 'analytics/widgets/analytics_empty_state.dart';
import 'analytics/widgets/analytics_header.dart';
import 'analytics/widgets/analytics_history_edit_modal.dart';
import 'analytics/widgets/analytics_history_section.dart';
import 'analytics/widgets/analytics_score_card.dart';
import 'analytics/widgets/analytics_summary_grid.dart';
import 'analytics/widgets/analytics_weekly_review.dart';

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
      'sleep': [70, 72, 75],
      'energy': [77, 80, 83],
      'hrv': [30, 33, 35],
      'steps': [210000, 224000, 236000],
      'mood': [6.7, 7.1, 7.4],
    },
  };

  final List<AnalyticsHistoryEntry> _history = const [
    AnalyticsHistoryEntry(
      '12',
      'PM',
      'Magnesium Power Bowl',
      'Quinoa, Avocado, Kale',
      '450',
      AppColors.kTextMain,
    ),
    AnalyticsHistoryEntry(
      '08',
      'AM',
      'Oatmeal & Berries',
      'Rolled oats, Blueberry',
      '320',
      AppColors.kTextMain,
    ),
    AnalyticsHistoryEntry(
      '03',
      'PM',
      'Protein Smoothie',
      'Whey, Banana, Almond Milk',
      '260',
      AppColors.kTextMain,
    ),
    AnalyticsHistoryEntry(
      '07',
      'AM',
      'Morning Run',
      'Active Burn',
      '-240',
      AppColors.kAccentGreen,
    ),
    AnalyticsHistoryEntry(
      '06',
      'AM',
      'Hydration',
      'Water intake',
      '+500ml',
      AppColors.kTextMain,
    ),
    AnalyticsHistoryEntry(
      '06',
      'AM',
      'Sleep Summary',
      '7h 25m, Restorative',
      '74',
      AppColors.kTextMain,
    ),
  ];

  final Map<String, List<double>> _fallbackSeries = const {
    'W': [1800, 2000, 1900, 2100, 2050, 2200, 1950],
    'M': [18600, 19400, 18800, 20100],
    '3M': [76000, 78200, 79900],
  };

  void _onNavTapped(int index) {
    if (index == 2) {
      return;
    }
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlannerScreen()),
      );
      return;
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  void _onFabTapped() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CaptureScreen()),
    );
  }

  void _selectRange(String range) {
    setState(() {
      _range = range;
    });
  }

  void _selectMetricA(String metric) {
    setState(() {
      _metricA = metric;
    });
  }

  void _selectMetricB(String metric) {
    setState(() {
      _metricB = metric;
    });
  }

  List<double> _seriesFor(String metric) {
    final series = _chartData[_range]?[metric] ?? const [];
    if (series.isNotEmpty) {
      return series;
    }
    return _fallbackSeries[_range] ?? const [0, 1];
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(milliseconds: 1200)),
    );
  }

  void _openHistoryEdit(AnalyticsHistoryEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AnalyticsHistoryEditModal(
          entry: entry,
          onSave: () {
            Navigator.pop(context);
            _showToast('Entry updated');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = _xAxis[_range] ?? const [];
    final primary = _seriesFor(_metricA);
    final secondary = _seriesFor(_metricB);

    return Scaffold(
      backgroundColor: AppColors.kBgBody,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                const AnalyticsHeader(),
                if (!_hasData)
                  AnalyticsEmptyState(
                    onLoadDemo: () => setState(() => _hasData = true),
                  ),
                if (_hasData) ...[
                  const AnalyticsScoreCard(),
                  const AnalyticsSummaryGrid(),
                  const AnalyticsWeeklyReview(),
                  AnalyticsCorrelationsCard(
                    range: _range,
                    onRangeChanged: _selectRange,
                    metricA: _metricA,
                    metricB: _metricB,
                    metricLabels: _metricLabels,
                    onMetricAChanged: _selectMetricA,
                    onMetricBChanged: _selectMetricB,
                    primary: primary,
                    secondary: secondary,
                    labels: labels,
                  ),
                  AnalyticsHistorySection(
                    history: _history,
                    onEdit: _openHistoryEdit,
                  ),
                ],
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
