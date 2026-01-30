import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/ui/pages/capture/models/food_item.dart';
import 'package:bio_ai/ui/pages/capture/widgets/meal_detail_modal.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_screen_body.dart';
import 'package:bio_ai/ui/pages/capture/widgets/custom_food_dialog.dart';
import 'package:bio_ai/ui/pages/capture/widgets/log_dialog.dart';
import 'package:bio_ai/ui/pages/capture/capture_state.dart';
import 'package:bio_ai/core/config.dart';
import 'package:bio_ai/app/di/injectors.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final CaptureScreenStateHolder _s = CaptureScreenStateHolder();

  Future<void> _captureAndUpload() async {
    final cam = ref.read(cameraServiceProvider);
    final fatSecret = ref.read(fatSecretServiceProvider);
    try {
      if (!cam.isInitialized) await cam.initialize();
      final file = await cam.takePhoto();

      // Show processing indicator
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Analyzing image...')));
      }

      // Upload and recognize using FatSecret API
      final result = await fatSecret.uploadAndRecognize(file.path);

      if (result['error'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recognition failed: ${result['error']}')),
          );
        }
        return;
      }

      // Parse recognition results
      final recognition = result['recognition'];
      if (recognition != null && recognition['foods'] != null) {
        final foods = recognition['foods'] as List;
        if (foods.isNotEmpty) {
          // Convert FatSecret response to FoodItem and add
          for (var food in foods.take(3)) {
            final item = _parseFatSecretFood(food);
            if (item != null) {
              _addItem(item);
            }
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Found ${foods.length} food items!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No food detected in image')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Capture/upload failed: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Seed items & results from local catalog in the service
    if (_s.searchService.catalog.isNotEmpty) {
      final seed = _s.searchService.catalog.firstWhere(
        (item) => item.name == 'Ribeye Steak',
        orElse: () => _s.searchService.catalog.first,
      );
      _s.items.add(seed);
      _s.results = List<FoodItem>.from(_s.searchService.catalog);
    } else {
      _s.results = [];
    }
  }

  @override
  void dispose() {
    _s.dispose();

    super.dispose();
  }

  void _openSheet() => setState(() => _s.sheetOpen = true);

  void _closeSheet() => setState(() => _s.sheetOpen = false);

  void _openSearch() {
    setState(() {
      _s.searchOpen = true;
      _s.mode = 'search';
    });
  }

  void _closeSearch() => setState(() {
    _s.searchOpen = false;
    _s.mode = 'scan';
  });

  void _toggleQuickSwitch() =>
      setState(() => _s.quickSwitchOpen = !_s.quickSwitchOpen);

  void _toggleBarcode() {
    setState(() {
      _s.barcodeOpen = !_s.barcodeOpen;
      _s.barcodeFound = false;
      _s.barcodeItem = null;
      _s.barcodeScanning = true;
    });
  }

  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (_s.barcodeFound || !_s.barcodeOpen) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _s.barcodeScanning = false);

    // Look up barcode via FatSecret API
    final fatSecret = ref.read(fatSecretServiceProvider);
    final result = await fatSecret.lookupBarcode(barcode.rawValue!);

    if (result['error'] != null || result['food'] == null) {
      if (mounted) {
        setState(() {
          _s.barcodeFound = false;
          _s.barcodeScanning = false;
        });
        _showToast('Barcode not found in database');
      }
      return;
    }

    // Parse FatSecret food response
    final foodItem = _parseFatSecretFood(result['food']);
    if (foodItem != null && mounted) {
      setState(() {
        _s.barcodeFound = true;
        _s.barcodeItem = foodItem;
        _s.barcodeScanning = false;
      });
    }
  }

  void _addItem(FoodItem item) {
    setState(() => _s.items.add(item));
    _openSheet();
    _showToast('Added ${item.name}');
  }

  void _removeItem(int index) {
    setState(() => _s.items.removeAt(index));
    _showToast('Item removed');
  }

  FoodItem? _parseFatSecretFood(dynamic food) {
    try {
      final name = food['food_name'] ?? food['name'] ?? 'Unknown Food';
      final description = food['food_description'] ?? food['description'] ?? '';

      // Parse nutrition from description (FatSecret format)
      double cals = 0, protein = 0, fat = 0;
      if (description.isNotEmpty) {
        final calMatch = RegExp(r'(\d+\.?\d*)\s*kcal').firstMatch(description);
        final proteinMatch = RegExp(
          r'Protein:\s*(\d+\.?\d*)g',
        ).firstMatch(description);
        final fatMatch = RegExp(r'Fat:\s*(\d+\.?\d*)g').firstMatch(description);

        if (calMatch != null) cals = double.tryParse(calMatch.group(1)!) ?? 0;
        if (proteinMatch != null)
          protein = double.tryParse(proteinMatch.group(1)!) ?? 0;
        if (fatMatch != null) fat = double.tryParse(fatMatch.group(1)!) ?? 0;
      }

      return FoodItem(
        name: name,
        desc: description,
        cals: cals,
        protein: protein,
        fat: fat,
        image: food['food_image'] ?? food['image'],
      );
    } catch (e) {
      print('Error parsing FatSecret food: $e');
      return null;
    }
  }

  void _filterSearch(String query) {
    _s.searchDebounce?.cancel();
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _s.results = List<FoodItem>.from(_s.searchService.catalog);
        _s.searching = false;
      });
      return;
    }

    // Immediate local filter for instant feedback
    final lower = q.toLowerCase();
    setState(() {
      _s.results = _s.searchService.catalog
          .where((item) => item.name.toLowerCase().contains(lower))
          .toList();
      _s.searching = true;
    });

    _s.searchDebounce = Timer(const Duration(seconds: 1), () async {
      // Use FatSecret API for search
      final fatSecret = ref.read(fatSecretServiceProvider);
      final result = await fatSecret.searchFood(q);

      if (result['error'] == null && result['foods'] != null) {
        final foodsData = result['foods'];
        final foodList = foodsData['food'] as List?;
        if (foodList != null) {
          final items = foodList
              .map((f) => _parseFatSecretFood(f))
              .whereType<FoodItem>()
              .toList();
          if (mounted) {
            setState(() {
              _s.results = items;
              _s.searching = false;
            });
          }
          return;
        }
      }

      // Fallback to local search
      final res = await _s.searchService.search(q);
      if (mounted) {
        setState(() {
          _s.results = res;
          _s.searching = false;
        });
      }
    });
  }

  // Use centralized MealDetailModal for details
  void _openMealModal(FoodItem item) async {
    final added = await showDialog<FoodItem?>(
      context: context,
      builder: (_) => MealDetailModal(
        item: item,
        loadFatSecret: _s.searchService.fetchFatSecretByName,
      ),
    );
    if (added != null) _addItem(added);
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
      ),
    );
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
        mode: _s.mode,
        portionOptions: _s.portionOptions,
        totalCals: _totalCals,
        totalProtein: _totalProtein,
        totalFat: _totalFat,
        controller: _s.searchController,
        isSearching: _s.searching,
        barcodeItem: _s.barcodeItem,
        onOpenSearch: _openSearch,
        onCloseSearch: _closeSearch,
        onToggleBarcode: _toggleBarcode,
        onBarcodeDetected: _handleBarcodeDetected,
        onToggleQuickSwitch: _toggleQuickSwitch,
        onNavigateFromQuick: _navigateFromQuick,
        onAddItem: _addItem,
        onRemoveItem: _removeItem,
        onPortionChanged: (i, p) =>
            setState(() => _s.items[i].portionIndex = p),
        onCreateCustom: () async {
          final custom = await showCustomFoodDialog(
            context,
            initialName: _s.searchController.text,
          );
          if (custom != null) {
            _addItem(custom);
            _s.searchController.clear();
            _filterSearch('');
          }
        },
        onLog: () {
          if (_s.offlineMode) {
            _showToast('Saved offline. Upload queued.');
            _closeSheet();
            return;
          }
          showLogDialog(
            context,
            onViewDiary: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
            onClose: _closeSheet,
          );
        },
        onAddCaffeine: () => _addItem(_s.searchService.catalog[0]),
        onAddAlcohol: () => _addItem(_s.searchService.catalog[1]),
        onQueryChanged: _filterSearch,
        onTapItem: _openMealModal,
        onCapturePhoto: _captureAndUpload,
      ),
    );
  }

  void _navigateFromQuick(Widget screen) {
    _toggleQuickSwitch();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
