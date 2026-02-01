import 'package:flutter/material.dart';
import '../analytics_screen.dart';
import '../capture_screen.dart';
import '../dashboard_screen.dart';
import '../settings_screen.dart';

void showPlannerToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1200),
    ),
  );
}

void onPlannerNavTapped(BuildContext context, int index) {
  if (index == 1) {
    return;
  }
  if (index == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
    return;
  }
  if (index == 2) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
    );
    return;
  }
  if (index == 3) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}

void onPlannerFabTapped(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const CaptureScreen()),
  );
}
