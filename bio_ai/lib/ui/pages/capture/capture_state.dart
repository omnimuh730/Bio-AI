import 'dart:async';

import 'package:flutter/material.dart';

import 'capture_models.dart';
import 'capture_search_service.dart';

class CaptureScreenStateHolder {
  final TextEditingController searchController = TextEditingController();

  bool sheetOpen = false;
  bool searchOpen = false;
  bool offlineMode = false;
  bool barcodeOpen = false;
  bool barcodeFound = false;
  bool barcodeScanning = false;
  bool quickSwitchOpen = false;

  String mode = 'scan';
  final List<double> portionOptions = [0.75, 1.0, 1.5];
  final List<FoodItem> items = [];
  List<FoodItem> results = [];

  Timer? barcodeTimer;

  final FoodSearchService searchService = FoodSearchService();
  Timer? searchDebounce;
  bool searching = false;

  FoodItem? barcodeItem;
  Map<String, dynamic>? barcodeFullData;
  String? barcodePendingConfirmation;

  void dispose() {
    barcodeTimer?.cancel();
    searchDebounce?.cancel();
    searchController.dispose();
  }
}
