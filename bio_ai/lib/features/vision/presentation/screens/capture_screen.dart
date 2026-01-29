import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/ui/pages/capture/models/food_item.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_analysis_sheet.dart';
import 'package:bio_ai/ui/pages/capture_screen.dart' as legacy_capture;
import 'package:bio_ai/ui/pages/capture/widgets/capture_barcode_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_bottom_controls.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_offline_banner.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_quick_switch.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_reticle.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_search_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_top_overlay.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _sheetOpen = false;
  bool _searchOpen = false;
  bool _offlineMode = false;
  bool _barcodeOpen = false;
  bool _barcodeFound = false;
  bool _quickSwitchOpen = false;

  String _mode = 'scan';
  final List<double> _portionOptions = [0.75, 1.0, 1.5];
  final List<FoodItem> _items = [];
  List<FoodItem> _results = [];

  Timer? _barcodeTimer;

  final List<FoodItem> _catalog = [
    FoodItem(
      name: 'Cold Brew Coffee',
      desc: 'Caffeine - 5 kcal',
      cals: 5,
      protein: 0,
      fat: 0,
      impact: 'caffeine',
      image:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Gin and Tonic',
      desc: 'Alcohol - 200 kcal',
      cals: 200,
      protein: 0,
      fat: 0,
      impact: 'alcohol',
      image:
          'https://images.unsplash.com/photo-1461009683692-68a47c8a75fd?auto=format&fit=crop&w=150&q=80',
    ),
    // ... rest omitted for brevity (copied from ui source)
  ];

  // rest of implementation copied from ui/pages/capture_screen.dart; uses pitch Provider for overlay

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For now, reuse the original capture implementation to avoid duplicating logic.
    // This will be refactored into feature-scoped widgets later.
    return const _LegacyCaptureWrapper();
  }
}

// Simple adapter to use the existing capture screen implementation while moving navigation
class _LegacyCaptureWrapper extends StatelessWidget {
  const _LegacyCaptureWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const legacy_capture.CaptureScreen();
  }
}
