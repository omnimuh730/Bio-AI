import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/planner_screen.dart' as ui;

/// Thin wrapper: forward to the presentation implementation which holds the
/// full logic (providers, diagnostics, services).
class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) => const ui.PlannerScreen();
}
