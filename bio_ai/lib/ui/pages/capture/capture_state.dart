import 'dart:async';
import 'package:flutter/material.dart';
import '../capture/models/food_item.dart';
import 'services/food_search_service.dart';

class CaptureScreenStateHolder {
  final TextEditingController searchController = TextEditingController();

  bool sheetOpen = false;
  bool searchOpen = false;
  bool offlineMode = false;
  bool barcodeOpen = false;
  bool barcodeFound = false;
  bool quickSwitchOpen = false;

  String mode = 'scan';
  final List<double> portionOptions = [0.75, 1.0, 1.5];
  final List<FoodItem> items = [];
  List<FoodItem> results = [];

  Timer? barcodeTimer;

  final FoodSearchService searchService = FoodSearchService();
  Timer? searchDebounce;
  bool searching = false;

  final FoodItem barcodeItem = FoodItem(
    name: 'Blueberry Protein Bar',
    desc: 'Packaged Snack - 220 kcal',
    cals: 220,
    protein: 12,
    fat: 9,
    image:
        'https://images.unsplash.com/photo-1543339318-b43dc53e19e6?auto=format&fit=crop&w=150&q=80',
  );

  void dispose() {
    barcodeTimer?.cancel();
    searchDebounce?.cancel();
    searchController.dispose();
  }
}
