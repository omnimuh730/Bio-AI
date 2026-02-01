import 'package:flutter/material.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:bio_ai/ui/pages/capture/capture_models.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_analysis_sheet.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_barcode_confirmation_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_barcode_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_barcode_result_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_bottom_controls.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_camera_background.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_offline_banner.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_quick_switch.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_reticle.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_search_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_top_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/pitch_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CaptureScreenBody extends StatelessWidget {
  final List<FoodItem> items;
  final List<FoodItem> results;
  final bool sheetOpen;
  final bool searchOpen;
  final bool offlineMode;
  final bool barcodeOpen;
  final bool barcodeFound;
  final bool barcodeScanning;
  final String? barcodePendingConfirmation;
  final Map<String, dynamic>? barcodeFullData;
  final String mode;
  final List<double> portionOptions;
  final double totalCals;
  final double totalProtein;
  final double totalFat;
  final TextEditingController controller;
  final bool isSearching;
  final FoodItem? barcodeItem;

  final VoidCallback onOpenSearch;
  final VoidCallback onCloseSearch;
  final VoidCallback onToggleBarcode;
  final VoidCallback onCloseBarcodeResult;
  final void Function(FoodItem) onAddBarcodeItem;
  final VoidCallback onConfirmBarcode;
  final VoidCallback onCancelBarcode;
  final void Function(BarcodeCapture)? onBarcodeDetected;
  final VoidCallback onToggleQuickSwitch;
  final void Function(Widget) onNavigateFromQuick;
  final void Function(FoodItem) onAddItem;
  final void Function(int) onRemoveItem;
  final void Function(int, int) onPortionChanged;
  final VoidCallback onCreateCustom;
  final VoidCallback onLog;
  final VoidCallback onAddCaffeine;
  final VoidCallback onAddAlcohol;
  final void Function(String) onQueryChanged;
  final void Function(FoodItem) onTapItem;
  final Future<void> Function()? onCapturePhoto;

  const CaptureScreenBody({
    super.key,
    required this.items,
    required this.results,
    required this.sheetOpen,
    required this.searchOpen,
    required this.offlineMode,
    required this.barcodeOpen,
    required this.barcodeFound,
    required this.barcodeScanning,
    this.barcodePendingConfirmation,
    this.barcodeFullData,
    required this.mode,
    required this.portionOptions,
    required this.totalCals,
    required this.totalProtein,
    required this.totalFat,
    required this.controller,
    required this.isSearching,
    required this.barcodeItem,
    required this.onOpenSearch,
    required this.onCloseSearch,
    required this.onToggleBarcode,
    required this.onCloseBarcodeResult,
    required this.onAddBarcodeItem,
    required this.onConfirmBarcode,
    required this.onCancelBarcode,
    this.onBarcodeDetected,
    required this.onToggleQuickSwitch,
    required this.onNavigateFromQuick,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onPortionChanged,
    required this.onCreateCustom,
    required this.onLog,
    required this.onAddCaffeine,
    required this.onAddAlcohol,
    required this.onQueryChanged,
    required this.onTapItem,
    this.onCapturePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CaptureCameraBackground(),
        CaptureTopOverlay(
          onClose: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          ),
          onQuickSwitch: onToggleQuickSwitch,
          quickSwitchOpen: false,
          onFlash: () {},
          onToggleOffline: () {},
          offlineMode: offlineMode,
          onBarcode: onToggleBarcode,
        ),
        const CaptureReticle(),
        CaptureOfflineBanner(visible: offlineMode),
        CaptureBottomControls(
          mode: mode,
          onModeChanged: (m) {
            if (m == 'search') onOpenSearch();
          },
          onShutterTap: () {
            if (mode == 'search') {
              onOpenSearch();
              return;
            }
            if (mode == 'barcode') {
              onToggleBarcode();
              return;
            }
            if (onCapturePhoto != null) onCapturePhoto!();
          },
        ),
        if (sheetOpen && !searchOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),
        CaptureAnalysisSheet(
          open: sheetOpen,
          searchOpen: searchOpen,
          items: items,
          totalCals: totalCals,
          totalProtein: totalProtein,
          totalFat: totalFat,
          offlineMode: offlineMode,
          onClose: () => Navigator.pop(context),
          onOpenSearch: onOpenSearch,
          onRemoveItem: onRemoveItem,
          onPortionChanged: onPortionChanged,
          onLog: onLog,
        ),
        CaptureSearchOverlay(
          open: searchOpen,
          controller: controller,
          onQueryChanged: onQueryChanged,
          onClose: onCloseSearch,
          onAddCaffeine: onAddCaffeine,
          onAddAlcohol: onAddAlcohol,
          results: results,
          isSearching: isSearching,
          onAddItem: onAddItem,
          onTapItem: onTapItem,
          onCreateCustom: onCreateCustom,
        ),
        if (!barcodeFound && barcodePendingConfirmation == null)
          CaptureBarcodeOverlay(
            open: barcodeOpen,
            found: barcodeFound,
            scanning: barcodeScanning,
            item: barcodeItem,
            onAdd: barcodeItem != null ? () => onAddItem(barcodeItem!) : null,
            onClose: onToggleBarcode,
            onNotFound: () {},
            onBarcodeDetected: onBarcodeDetected,
          ),
        if (barcodePendingConfirmation != null)
          CaptureBarcodeConfirmationOverlay(
            code: barcodePendingConfirmation!,
            onCancel: onCancelBarcode,
            onConfirm: onConfirmBarcode,
          ),
        if (barcodeFound && barcodeFullData != null)
          CaptureBarcodeResultOverlay(
            foodData: barcodeFullData!,
            item: barcodeItem,
            onAdd: barcodeItem != null
                ? () => onAddBarcodeItem(barcodeItem!)
                : () {},
            onClose: onCloseBarcodeResult,
          ),
        CaptureQuickSwitch(
          open: false,
          onClose: () {},
          onDashboard: () => onNavigateFromQuick(const DashboardScreen()),
          onPlanner: () => onNavigateFromQuick(const PlannerScreen()),
          onAnalytics: () => onNavigateFromQuick(const AnalyticsScreen()),
          onSettings: () => onNavigateFromQuick(const SettingsScreen()),
        ),
        const Positioned(top: 40, right: 16, child: PitchIndicator()),
      ],
    );
  }
}
