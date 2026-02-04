import 'package:bio_ai/services/streaming_service.dart';
import 'package:bio_ai/core/config.dart';

import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/mock_data.dart';

import 'package:bio_ai/ui/pages/dashboard/widgets/dashboard_setupcard.dart';
import 'package:bio_ai/ui/pages/dashboard/widgets/dashboard_dailyprocess.dart';
import 'package:bio_ai/ui/pages/dashboard/widgets/dashboard_vitals.dart';
import 'package:bio_ai/ui/pages/dashboard/widgets/dashboard_headerprofile.dart';
import 'package:bio_ai/ui/pages/dashboard/widgets/dashboard_aimeal.dart';
import 'package:bio_ai/ui/pages/dashboard/widgets/dashboard_hydration.dart';
import 'package:bio_ai/ui/pages/dashboard/widgets/dashboard_quicklog.dart';

import 'package:bio_ai/ui/pages/dashboard/dashboard_helper.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';

import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:bio_ai/features/vision/presentation/screens/capture_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _mealIndex = 0;
  final StreamingService _streaming = StreamingService.instance;

  @override
  void initState() {
    super.initState();
    if (AppConfig.isDevOrStage) {
      _streaming.start();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _swapMeal() {
    setState(() {
      _mealIndex = (_mealIndex + 1) % mockMeals.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).newSuggestionLoaded),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _logMeal() {
    showDialog(
      context: context,
      builder: (context) => LogMealModal(meal: mockMeals[_mealIndex]),
    );
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      return;
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgBody,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                const HeaderProfile(),
                const SetupCard(),

                SectionTitle(
                  localizations.liveVitals,
                  onRefresh: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.vitalsSynced)),
                    );
                  },
                ),
                VitalsGrid(streaming: _streaming),

                SectionTitle(localizations.aiSuggestion),
                AIMealCard(
                  meal: mockMeals[_mealIndex],
                  onSwap: _swapMeal,
                  onLog: _logMeal,
                ),

                SectionTitle(localizations.dailyFuel),
                const DailyProgressCard(),

                SectionTitle(localizations.hydration),
                const HydrationCard(),

                SectionTitle(
                  localizations.quickLog,
                  linkText: localizations.viewHistory,
                ),
                const QuickLogCard(),
              ],
            ),
          ),

          // Floating Navigation Bar
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingNavBar(
                selectedIndex: 0,
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
