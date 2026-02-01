import 'package:flutter/material.dart';
import 'package:bio_ai/ui/pages/capture_screen.dart' as ui;

/// Thin wrapper: forward to the presentation implementation which holds the
/// full logic (providers, diagnostics, services).
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) => const ui.CaptureScreen();
}
