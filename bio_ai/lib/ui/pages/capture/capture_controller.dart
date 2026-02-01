import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/ui/pages/capture/capture_helpers.dart';
import 'package:bio_ai/ui/pages/capture/capture_models.dart';
import 'package:bio_ai/ui/pages/capture/capture_state.dart';

class CaptureScreenController {
  final WidgetRef ref;
  final CaptureScreenStateHolder state;
  final void Function(VoidCallback) setState;
  final bool Function() isMounted;
  final void Function(String message) showSnackBar;
  final Future<FoodItem?> Function(FoodItem item) showMealDetailModal;
  final Future<FoodItem?> Function(String initialName) showCustomFoodDialog;
  final Future<void> Function(VoidCallback onViewDiary) showLogDialog;

  CaptureScreenController({
    required this.ref,
    required this.state,
    required this.setState,
    required this.isMounted,
    required this.showSnackBar,
    required this.showMealDetailModal,
    required this.showCustomFoodDialog,
    required this.showLogDialog,
  });

  void openSheet() => setState(() => state.sheetOpen = true);

  void closeSheet() => setState(() => state.sheetOpen = false);

  void openSearch() {
    setState(() {
      state.searchOpen = true;
      state.mode = 'search';
    });
  }

  void closeSearch() => setState(() {
    state.searchOpen = false;
    state.mode = 'scan';
  });

  void toggleQuickSwitch() =>
      setState(() => state.quickSwitchOpen = !state.quickSwitchOpen);

  void toggleBarcode() {
    setState(() {
      state.barcodeOpen = !state.barcodeOpen;
      state.barcodeFound = false;
      state.barcodeItem = null;
      state.barcodeFullData = null;
      state.barcodePendingConfirmation = null;
      state.barcodeScanning = true;
    });
  }

  void closeBarcodeResult() {
    setState(() {
      state.barcodeFound = false;
      state.barcodeItem = null;
      state.barcodeFullData = null;
      state.barcodeScanning = true;
    });
  }

  void addItem(FoodItem item) {
    setState(() => state.items.add(item));
    openSheet();
    showSnackBar('Added ${item.name}');
  }

  void removeItem(int index) {
    setState(() => state.items.removeAt(index));
    showSnackBar('Item removed');
  }

  void addBarcodeItemAndClose(FoodItem item) {
    addItem(item);
    setState(() {
      state.barcodeOpen = false;
      state.barcodeFound = false;
      state.barcodeItem = null;
      state.barcodeFullData = null;
      state.barcodeScanning = false;
    });
  }

  Future<void> captureAndUpload() async {
    final cam = ref.read(cameraServiceProvider);
    final fatSecret = ref.read(fatSecretServiceProvider);
    try {
      if (!cam.isInitialized) await cam.initialize();
      final file = await cam.takePhoto();

      if (isMounted()) {
        showSnackBar('Analyzing image...');
      }

      final result = await fatSecret.uploadAndRecognize(file.path);

      if (result['error'] != null) {
        if (isMounted()) {
          showSnackBar('Recognition failed: ${result['error']}');
        }
        return;
      }

      final recognition = result['recognition'];
      if (recognition != null && recognition['foods'] != null) {
        final foods = recognition['foods'] as List;
        if (foods.isNotEmpty) {
          for (var food in foods.take(3)) {
            final item = parseFatSecretFood(food);
            if (item != null) {
              addItem(item);
            }
          }
          if (isMounted()) {
            showSnackBar('Found ${foods.length} food items!');
          }
        } else {
          if (isMounted()) {
            showSnackBar('No food detected in image');
          }
        }
      }
    } catch (e) {
      if (isMounted()) {
        showSnackBar('Capture/upload failed: $e');
      }
    }
  }

  Future<void> handleBarcodeDetected(BarcodeCapture capture) async {
    if (state.barcodeFound ||
        !state.barcodeOpen ||
        state.barcodePendingConfirmation != null) {
      return;
    }

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      state.barcodeScanning = false;
      state.barcodePendingConfirmation = barcode.rawValue!;
    });
  }

  Future<void> confirmBarcodeLookup() async {
    final barcodeValue = state.barcodePendingConfirmation;
    if (barcodeValue == null) return;

    final fatSecret = ref.read(fatSecretServiceProvider);
    final result = await fatSecret.lookupBarcode(barcodeValue);

    if (result['error'] != null) {
      if (isMounted()) {
        setState(() {
          state.barcodeFound = false;
          state.barcodeScanning = false;
          state.barcodePendingConfirmation = null;
          state.barcodeOpen = false;
        });
        showSnackBar('Barcode not found in database');
      }
      return;
    }

    final foodData = result['food'];
    if (foodData == null) {
      if (isMounted()) {
        setState(() {
          state.barcodeFound = false;
          state.barcodeScanning = false;
          state.barcodePendingConfirmation = null;
          state.barcodeOpen = false;
        });
        showSnackBar('Barcode not found in database');
      }
      return;
    }

    final foodItem = parseFatSecretFood(foodData);

    if (foodItem != null && isMounted()) {
      setState(() {
        state.barcodeFound = true;
        state.barcodeItem = foodItem;
        state.barcodeFullData = foodData;
        state.barcodeScanning = false;
        state.barcodePendingConfirmation = null;
      });
    } else {
      if (isMounted()) {
        setState(() {
          state.barcodeFound = false;
          state.barcodeScanning = false;
          state.barcodePendingConfirmation = null;
          state.barcodeOpen = false;
        });
        showSnackBar('Could not parse food data');
      }
    }
  }

  void cancelBarcodeLookup() {
    setState(() {
      state.barcodePendingConfirmation = null;
      state.barcodeScanning = true;
    });
  }

  void filterSearch(String query) {
    state.searchDebounce?.cancel();
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        state.results = List<FoodItem>.from(state.searchService.catalog);
        state.searching = false;
      });
      return;
    }

    final lower = q.toLowerCase();
    setState(() {
      state.results = state.searchService.catalog
          .where((item) => item.name.toLowerCase().contains(lower))
          .toList();
      state.searching = true;
    });

    state.searchDebounce = Timer(const Duration(seconds: 1), () async {
      final fatSecret = ref.read(fatSecretServiceProvider);
      final result = await fatSecret.searchFood(q);

      if (result['error'] == null && result['foods'] != null) {
        final foodsData = result['foods'];
        final foodList = foodsData['food'] as List?;
        if (foodList != null) {
          final items = foodList
              .map((f) => parseFatSecretFood(f))
              .whereType<FoodItem>()
              .toList();
          if (isMounted()) {
            setState(() {
              state.results = items;
              state.searching = false;
            });
          }
          return;
        }
      }

      final res = await state.searchService.search(q);
      if (isMounted()) {
        setState(() {
          state.results = res;
          state.searching = false;
        });
      }
    });
  }

  Future<void> openMealModal(FoodItem item) async {
    final added = await showMealDetailModal(item);
    if (added != null) addItem(added);
  }

  Future<void> createCustomFood() async {
    final custom = await showCustomFoodDialog(state.searchController.text);
    if (custom != null) {
      addItem(custom);
      state.searchController.clear();
      filterSearch('');
    }
  }

  void logMeal({required VoidCallback onViewDiary}) {
    if (state.offlineMode) {
      showSnackBar('Saved offline. Upload queued.');
      closeSheet();
      return;
    }
    showLogDialog(onViewDiary);
  }
}
