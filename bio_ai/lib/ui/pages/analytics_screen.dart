import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';

import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:bio_ai/features/vision/presentation/screens/capture_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
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
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
      ),
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
      backgroundColor: AppColors.bgBody,
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

class AnalyticsHeader extends StatelessWidget {
  const AnalyticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Analysis',
            style: AppTextStyles.dmSans22Bold.copyWith(
              color: AppColors.textMain,
            ),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            size: 20,
            color: AppColors.textMain,
          ),
        ],
      ),
    );
  }
}

class AnalyticsEmptyState extends StatelessWidget {
  final VoidCallback onLoadDemo;

  const AnalyticsEmptyState({super.key, required this.onLoadDemo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x224B7BFF), Colors.transparent],
              ),
            ),
            child: const Icon(Icons.eco, color: AppColors.accentBlue, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Gathering your bio-data...', style: AppTextStyles.dmSans16Bold),
          const SizedBox(height: 8),
          Text(
            'Log your first meals and sync your devices to unlock trends.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLoadDemo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Load Demo Data',
                style: AppTextStyles.label.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsScoreCard extends StatelessWidget {
  const AnalyticsScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 90,
              child: CustomPaint(
                painter: AnalyticsGaugePainter(
                  progress: 0.88,
                  background: const Color(0xFFF1F5F9),
                  foreground: AppColors.accentBlue,
                ),
                child: const SizedBox(width: 180, height: 90),
              ),
            ),
            Text(
              '88',
              style: AppTextStyles.heading1.copyWith(color: AppColors.textMain),
            ),
            Text(
              'Excellent Energy',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.accentBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Trend up: Your score improved by 12% this week. '
                      'Consistent protein intake post-workout has improved your recovery speed.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF334155),
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

class AnalyticsSummaryGrid extends StatelessWidget {
  const AnalyticsSummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.6,
        children: const [
          AnalyticsSummaryCard(
            icon: Icons.local_fire_department,
            label: 'Calories',
            value: '1,840 / 2,300',
            color: AppColors.accentBlue,
            bg: Color(0x1A4B7BFF),
          ),
          AnalyticsSummaryCard(
            icon: Icons.biotech,
            label: 'Protein',
            value: '118g / 140g',
            color: AppColors.accentPurple,
            bg: Color(0x1A8B5CF6),
          ),
          AnalyticsSummaryCard(
            icon: Icons.directions_run,
            label: 'Active Burn',
            value: '620 kcal',
            color: AppColors.accentGreen,
            bg: Color(0x1A10B981),
          ),
          AnalyticsSummaryCard(
            icon: Icons.nightlight_outlined,
            label: 'Sleep Score',
            value: '74 / 100',
            color: AppColors.textSecondary,
            bg: Color(0xFFF1F5F9),
          ),
        ],
      ),
    );
  }
}

class AnalyticsSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const AnalyticsSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.dmSans16Bold.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsWeeklyReview extends StatelessWidget {
  const AnalyticsWeeklyReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  size: 18,
                  color: AppColors.accentBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly AI Review',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'You hit your protein goal 5 of 7 days. '
                'Sleep quality improved by 10%. I will stop suggesting oatmeal for now.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsCorrelationsCard extends StatelessWidget {
  final String range;
  final ValueChanged<String> onRangeChanged;
  final String metricA;
  final String metricB;
  final Map<String, String> metricLabels;
  final ValueChanged<String> onMetricAChanged;
  final ValueChanged<String> onMetricBChanged;
  final List<double> primary;
  final List<double> secondary;
  final List<String> labels;

  const AnalyticsCorrelationsCard({
    super.key,
    required this.range,
    required this.onRangeChanged,
    required this.metricA,
    required this.metricB,
    required this.metricLabels,
    required this.onMetricAChanged,
    required this.onMetricBChanged,
    required this.primary,
    required this.secondary,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Correlations', style: AppTextStyles.dmSans16Bold),
              AnalyticsTimeToggle(selected: range, onChanged: onRangeChanged),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsMetricSelector(
                        label: metricLabels[metricA] ?? 'Metric A',
                        color: AppColors.accentBlue,
                        background: const Color(0x1A4B7BFF),
                        options: metricLabels.keys.take(5).toList(),
                        onSelected: onMetricAChanged,
                        formatter: (key) => metricLabels[key] ?? key,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnalyticsMetricSelector(
                        label: metricLabels[metricB] ?? 'Metric B',
                        color: AppColors.accentPurple,
                        background: const Color(0x1A8B5CF6),
                        options: metricLabels.keys.skip(5).take(5).toList(),
                        onSelected: onMetricBChanged,
                        formatter: (key) => metricLabels[key] ?? key,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: AnalyticsCorrelationChartPainter(
                      primary: primary,
                      secondary: secondary,
                      primaryColor: AppColors.accentBlue,
                      secondaryColor: AppColors.accentPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels
                      .map(
                        (label) => Text(label, style: AppTextStyles.labelSmall),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsTimeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const AnalyticsTimeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: ['W', 'M', '3M']
            .map(
              (label) => GestureDetector(
                onTap: () => onChanged(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected == label
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected == label
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected == label
                          ? AppColors.textMain
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class AnalyticsMetricSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final Color color;
  final Color background;
  final String Function(String) formatter;

  const AnalyticsMetricSelector({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
    required this.color,
    required this.background,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              child: Text(
                formatter(option),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMain,
                ),
              ),
            ),
          )
          .toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      offset: const Offset(0, 42),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

class AnalyticsCorrelationChartPainter extends CustomPainter {
  final List<double> primary;
  final List<double> secondary;
  final Color primaryColor;
  final Color secondaryColor;

  AnalyticsCorrelationChartPainter({
    required this.primary,
    required this.secondary,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (final y in [
      size.height * 0.25,
      size.height * 0.5,
      size.height * 0.75,
    ]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final all = [...primary, ...secondary];
    if (all.isEmpty) {
      return;
    }
    final minVal = all.reduce(min);
    final maxVal = all.reduce(max);
    final range = (maxVal - minVal).abs() < 0.0001 ? 1.0 : maxVal - minVal;

    Path makePath(List<double> values) {
      if (values.isEmpty) {
        return Path();
      }
      final step = values.length == 1
          ? size.width
          : size.width / (values.length - 1);
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = step * i;
        final ratio = (values[i] - minVal) / range;
        final y = size.height - (ratio * size.height);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final secondaryPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(makePath(primary), primaryPaint);
    _drawDashedPath(canvas, makePath(secondary), secondaryPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 6.0;
    const dashGap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segmentLength = distance + dashLength < metric.length
            ? dashLength
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + segmentLength);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnalyticsCorrelationChartPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}

class AnalyticsHistorySection extends StatelessWidget {
  final List<AnalyticsHistoryEntry> history;
  final ValueChanged<AnalyticsHistoryEntry> onEdit;

  const AnalyticsHistorySection({
    super.key,
    required this.history,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's History", style: AppTextStyles.dmSans16Bold),
          const SizedBox(height: 12),
          Column(
            children: history
                .map(
                  (entry) => AnalyticsHistoryCard(
                    entry: entry,
                    onEdit: () => onEdit(entry),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class AnalyticsHistoryCard extends StatelessWidget {
  final AnalyticsHistoryEntry entry;
  final VoidCallback onEdit;

  const AnalyticsHistoryCard({
    super.key,
    required this.entry,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      entry.hour,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      entry.meridiem,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: AppTextStyles.dmSans14SemiBold.copyWith(
                      color: AppColors.textMain,
                    ),
                  ),
                  Text(
                    entry.subtitle,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.value,
                style: AppTextStyles.dmSans14SemiBold.copyWith(
                  color: entry.valueColor,
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Edit',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnalyticsHistoryEditModal extends StatelessWidget {
  final AnalyticsHistoryEntry entry;
  final VoidCallback onSave;

  const AnalyticsHistoryEditModal({
    super.key,
    required this.entry,
    required this.onSave,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Entry',
                  style: AppTextStyles.heading3.copyWith(
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
              entry.title,
              style: AppTextStyles.heading3.copyWith(color: AppColors.textMain),
            ),
            const SizedBox(height: 6),
            Text(
              entry.subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Value',
                hintText: entry.value,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: AppTextStyles.labelSmall,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: AppColors.textMain,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Cancel', style: AppTextStyles.labelSmall),
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

class AnalyticsGaugePainter extends CustomPainter {
  final double progress;
  final Color background;
  final Color foreground;

  AnalyticsGaugePainter({
    required this.progress,
    required this.background,
    required this.foreground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height);
    final rect = Rect.fromCircle(center: center, radius: radius - 8);

    stroke.color = background;
    canvas.drawArc(rect, pi, pi, false, stroke);

    stroke.color = foreground;
    canvas.drawArc(rect, pi, pi * progress, false, stroke);
  }

  @override
  bool shouldRepaint(covariant AnalyticsGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.background != background ||
        oldDelegate.foreground != foreground;
  }
}
