import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';

import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';

import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:bio_ai/features/vision/presentation/screens/capture_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';

import 'package:bio_ai/ui/pages/analytics/analytics_state.dart';
import 'package:bio_ai/ui/pages/analytics/analytics_helper.dart';

import 'package:bio_ai/ui/pages/analytics/widgets/analytics_header.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_empty_state.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_score_card.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_summary_grid.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_weekly_review.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_correlations_card.dart';
import 'package:bio_ai/ui/pages/analytics/widgets/analytics_history_section.dart';

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
    return AnalyticsData.seriesFor(_range, metric);
  }

  void _showToast(String message) {
    showAnalyticsToast(context, message);
  }

  void _openHistoryEdit(AnalyticsHistoryEntry entry) {
    openHistoryEditModal(context, entry, () => _showToast('Entry updated'));
  }

  @override
  Widget build(BuildContext context) {
    final labels = AnalyticsData.xAxis[_range] ?? const [];
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
                    metricLabels: AnalyticsData.metricLabels,
                    onMetricAChanged: _selectMetricA,
                    onMetricBChanged: _selectMetricB,
                    primary: primary,
                    secondary: secondary,
                    labels: labels,
                  ),
                  AnalyticsHistorySection(
                    history: AnalyticsData.mockHistory,
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
