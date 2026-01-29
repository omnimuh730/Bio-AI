import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../atoms/section_title.dart';
import '../molecules/header_profile.dart';
import '../organisms/ai_meal_card.dart';
import '../organisms/daily_progress_card.dart';
import '../organisms/floating_nav_bar.dart';
import '../organisms/hydration_card.dart';
import '../organisms/log_meal_modal.dart';
import '../organisms/quick_log_card.dart';
import '../organisms/setup_card.dart';
import '../organisms/vitals_grid.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'capture_screen.dart';
import 'planner_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _mealIndex = 0;

  void _swapMeal() {
    setState(() {
      _mealIndex = (_mealIndex + 1) % mockMeals.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New suggestion loaded'),
        duration: Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
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
                  'Live Vitals',
                  onRefresh: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vitals synced')),
                    );
                  },
                ),
                const VitalsGrid(),

                const SectionTitle('AI Suggestion'),
                AIMealCard(
                  meal: mockMeals[_mealIndex],
                  onSwap: _swapMeal,
                  onLog: _logMeal,
                ),

                const SectionTitle('Daily Fuel'),
                const DailyProgressCard(),

                const SectionTitle('Hydration'),
                const HydrationCard(),

                const SectionTitle('Quick Log', linkText: "View History"),
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
