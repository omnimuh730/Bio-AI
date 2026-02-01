import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/dashboard_screen.dart' as ui;

/// Thin wrapper: forward to the presentation implementation which holds the
/// full logic (providers, diagnostics, services).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const ui.DashboardScreen();
}
