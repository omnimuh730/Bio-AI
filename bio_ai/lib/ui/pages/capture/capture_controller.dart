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
    if (state.mode == 'barcode') {
      // In barcode mode, just toggle the barcode scanner
      toggleBarcode();
      return;
    }

    // In scan mode, capture photo and recognize food
    final cam = ref.read(cameraServiceProvider);
    final fatSecret = ref.read(fatSecretServiceProvider);

    setState(() => state.scanProcessing = true);

    try {
      if (!cam.isInitialized) await cam.initialize();
      final file = await cam.takePhoto();

      if (isMounted()) {
        showSnackBar('Analyzing image...');
      }

      final result = await fatSecret.uploadAndRecognize(file.path);

      if (result['error'] != null) {
        if (isMounted()) {
          setState(() => state.scanProcessing = false);
          showSnackBar('Recognition failed: ${result['error']}');
        }
        return;
      }

      final recognition = result['recognition'];
      if (recognition != null) {
        // FatSecret returns 'food_response' not 'foods'
        final foods = recognition['food_response'] as List?;
        if (foods != null && foods.isNotEmpty) {
          // Store recognized foods and show nutrition cards
          // Extract the nested 'food' object from each item for the nutrition card
          // Use deepConvertMap to properly convert all nested Map<dynamic,dynamic> to Map<String,dynamic>
          final foodMaps = <Map<String, dynamic>>[];
          for (final item in foods) {
            final itemMap = item as Map;
            // The nutrition card expects food_name, servings at top level
            // which are inside the 'food' nested object
            final foodObj = itemMap['food'];
            if (foodObj != null) {
              foodMaps.add(deepConvertMap(foodObj));
            }
          }

          if (foodMaps.isNotEmpty) {
            setState(() {
              state.scanResults = foodMaps;
              state.scanResultOpen = true;
              state.scanProcessing = false;
            });
            if (isMounted()) {
              showSnackBar('Found ${foodMaps.length} food item(s)!');
            }
          } else {
            if (isMounted()) {
              setState(() => state.scanProcessing = false);
              showSnackBar('No food data in response');
            }
          }
        } else {
          if (isMounted()) {
            setState(() => state.scanProcessing = false);
            showSnackBar('No food detected in image');
          }
        }
      } else {
        if (isMounted()) {
          setState(() => state.scanProcessing = false);
          showSnackBar('No recognition data received');
        }
      }
    } catch (e) {
      if (isMounted()) {
        setState(() => state.scanProcessing = false);
        showSnackBar('Capture/upload failed: $e');
      }
    }
  }

  void closeScanResult() {
    setState(() {
      state.scanResultOpen = false;
      state.scanResults = [];
    });
  }

  void addScanResultItem(Map<String, dynamic> foodData) {
    final item = parseFatSecretFood(foodData);
    if (item != null) {
      addItem(item);
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

  void logMeal({required VoidCallback onViewDiary}) {
    if (state.offlineMode) {
      showSnackBar('Saved offline. Upload queued.');
      closeSheet();
      return;
    }
    showLogDialog(onViewDiary);
  }
}
