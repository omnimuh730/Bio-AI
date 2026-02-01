import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/analytics_screen.dart' as ui;

/// Thin wrapper: forward to the presentation implementation which holds the
/// full logic (providers, diagnostics, services).
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) => const ui.AnalyticsScreen();
}
