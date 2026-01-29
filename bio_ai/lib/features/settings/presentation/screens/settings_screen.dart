import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/settings_screen.dart' as ui;

/// Thin wrapper: forward to the presentation implementation which holds the
/// full logic (providers, diagnostics, services).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const ui.SettingsScreen();
}
