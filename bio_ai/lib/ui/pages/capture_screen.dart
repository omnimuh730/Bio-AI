import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/ui/pages/capture/capture_models.dart';
import 'package:bio_ai/ui/pages/capture/capture_state.dart';
import 'package:bio_ai/ui/pages/capture/capture_controller.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_screen_body.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final CaptureScreenStateHolder _s = CaptureScreenStateHolder();

  CaptureScreenController get _controller => CaptureScreenController(
    ref: ref,
    state: _s,
    context: context,
    setState: setState,
    isMounted: () => mounted,
  );

  @override
  void initState() {
    super.initState();
    // Initialize with empty items list
    _s.results = _s.searchService.catalog.isNotEmpty
        ? List<FoodItem>.from(_s.searchService.catalog)
        : [];
  }

  @override
  void dispose() {
    _s.dispose();

    super.dispose();
  }

  double get _totalCals => _s.items.fold(
    0.0,
    (p, e) => p + e.cals * _s.portionOptions[e.portionIndex],
  );
  double get _totalProtein => _s.items.fold(
    0.0,
    (p, e) => p + e.protein * _s.portionOptions[e.portionIndex],
  );
  double get _totalFat => _s.items.fold(
    0.0,
    (p, e) => p + e.fat * _s.portionOptions[e.portionIndex],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CaptureScreenBody(
        items: _s.items,
        results: _s.results,
        sheetOpen: _s.sheetOpen,
        searchOpen: _s.searchOpen,
        offlineMode: _s.offlineMode,
        barcodeOpen: _s.barcodeOpen,
        barcodeFound: _s.barcodeFound,
        barcodeScanning: _s.barcodeScanning,
        barcodePendingConfirmation: _s.barcodePendingConfirmation,
        barcodeFullData: _s.barcodeFullData,
        mode: _s.mode,
        portionOptions: _s.portionOptions,
        totalCals: _totalCals,
        totalProtein: _totalProtein,
        totalFat: _totalFat,
        controller: _s.searchController,
        isSearching: _s.searching,
        barcodeItem: _s.barcodeItem,
        onOpenSearch: _controller.openSearch,
        onCloseSearch: _controller.closeSearch,
        onToggleBarcode: _controller.toggleBarcode,
        onCloseBarcodeResult: _controller.closeBarcodeResult,
        onAddBarcodeItem: _controller.addBarcodeItemAndClose,
        onConfirmBarcode: _controller.confirmBarcodeLookup,
        onCancelBarcode: _controller.cancelBarcodeLookup,
        onBarcodeDetected: _controller.handleBarcodeDetected,
        onToggleQuickSwitch: _controller.toggleQuickSwitch,
        onNavigateFromQuick: _navigateFromQuick,
        onAddItem: _controller.addItem,
        onRemoveItem: _controller.removeItem,
        onPortionChanged: (i, p) =>
            setState(() => _s.items[i].portionIndex = p),
        onCreateCustom: _controller.createCustomFood,
        onLog: () {
          _controller.logMeal(
            onViewDiary: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
          );
        },
        onAddCaffeine: () => _controller.addItem(_s.searchService.catalog[0]),
        onAddAlcohol: () => _controller.addItem(_s.searchService.catalog[1]),
        onQueryChanged: _controller.filterSearch,
        onTapItem: _controller.openMealModal,
        onCapturePhoto: _controller.captureAndUpload,
      ),
    );
  }

  void _navigateFromQuick(Widget screen) {
    _controller.toggleQuickSwitch();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
