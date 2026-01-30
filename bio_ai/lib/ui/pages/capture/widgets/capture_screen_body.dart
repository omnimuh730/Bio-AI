import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import '../../capture/models/food_item.dart';
import 'capture_analysis_sheet.dart';
import 'capture_barcode_overlay.dart';
import 'capture_bottom_controls.dart';
import 'capture_offline_banner.dart';
import 'capture_quick_switch.dart';
import 'capture_reticle.dart';
import 'capture_search_overlay.dart';
import 'capture_top_overlay.dart';

class CaptureScreenBody extends StatelessWidget {
  final List<FoodItem> items;
  final List<FoodItem> results;
  final bool sheetOpen;
  final bool searchOpen;
  final bool offlineMode;
  final bool barcodeOpen;
  final bool barcodeFound;
  final bool barcodeScanning;
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

  /// Optional callback invoked when shutter is pressed in scan mode.
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
        Consumer(
          builder: (context, ref, child) {
            final camInit = ref.watch(cameraInitProvider);
            return camInit.when(
              data: (_) {
                final cam = ref.read(cameraServiceProvider);
                if (cam.controller != null && cam.isInitialized) {
                  return CameraPreview(cam.controller!);
                }
                // fallback to static background until controller is ready
                return Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
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
            // default: capture photo
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
        CaptureQuickSwitch(
          open: false,
          onClose: () {},
          onDashboard: () => onNavigateFromQuick(const DashboardScreen()),
          onPlanner: () => onNavigateFromQuick(const PlannerScreen()),
          onAnalytics: () => onNavigateFromQuick(const AnalyticsScreen()),
          onSettings: () => onNavigateFromQuick(const SettingsScreen()),
        ),
        // Small debug / guidance overlay showing device pitch (gyro)
        const Positioned(top: 40, right: 16, child: _PitchIndicator()),
      ],
    );
  }
}

class _PitchIndicator extends ConsumerWidget {
  const _PitchIndicator();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchAsync = ref.watch(pitchProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: pitchAsync.when(
        data: (val) => Text(
          'Pitch: ${val.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white),
        ),
        loading: () => const SizedBox(
          width: 60,
          height: 14,
          child: LinearProgressIndicator(),
        ),
        error: (e, st) =>
            const Text('Pitch: —', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
