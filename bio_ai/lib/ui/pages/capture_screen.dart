import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/core/config.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';

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
      _s.barcodeFullData = null; // Clear full data
      _s.barcodePendingConfirmation = null;
      _s.barcodeScanning = true;
    });
  }

  void _closeBarcodeResult() {
    setState(() {
      _s.barcodeFound = false;
      _s.barcodeItem = null;
      _s.barcodeFullData = null;
      _s.barcodeScanning = true; // Re-enable scanning
    });
  }

  void _addBarcodeItemAndClose(FoodItem item) {
    _addItem(item);
    // Close barcode mode completely after adding
    setState(() {
      _s.barcodeOpen = false;
      _s.barcodeFound = false;
      _s.barcodeItem = null;
      _s.barcodeFullData = null;
      _s.barcodeScanning = false;
    });
  }

  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (_s.barcodeFound ||
        !_s.barcodeOpen ||
        _s.barcodePendingConfirmation != null) {
      return;
    }

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    // Stop scanning and show confirmation
    setState(() {
      _s.barcodeScanning = false;
      _s.barcodePendingConfirmation = barcode.rawValue!;
    });
  }

  Future<void> _confirmBarcodeLookup() async {
    final barcodeValue = _s.barcodePendingConfirmation;
    if (barcodeValue == null) return;

    // Look up barcode via FatSecret API
    final fatSecret = ref.read(fatSecretServiceProvider);
    final result = await fatSecret.lookupBarcode(barcodeValue);

    // Check for error response
    if (result['error'] != null) {
      if (mounted) {
        setState(() {
          _s.barcodeFound = false;
          _s.barcodeScanning = false;
          _s.barcodePendingConfirmation = null;
          _s.barcodeOpen = false;
        });
        _showToast('Barcode not found in database');
      }
      return;
    }

    // FatSecret barcode API returns food data directly at root level
    // Structure: {"food_id": {...}, "food": {...}}
    final foodData = result['food'];
    if (foodData == null) {
      if (mounted) {
        setState(() {
          _s.barcodeFound = false;
          _s.barcodeScanning = false;
          _s.barcodePendingConfirmation = null;
          _s.barcodeOpen = false;
        });
        _showToast('Barcode not found in database');
      }
      return;
    }

    // Parse FatSecret food response
    final foodItem = _parseFatSecretFood(foodData);

    if (foodItem != null && mounted) {
      setState(() {
        _s.barcodeFound = true;
        _s.barcodeItem = foodItem;
        _s.barcodeFullData = foodData; // Store complete JSON data
        _s.barcodeScanning = false;
        _s.barcodePendingConfirmation = null;
      });
    } else {
      if (mounted) {
        setState(() {
          _s.barcodeFound = false;
          _s.barcodeScanning = false;
          _s.barcodePendingConfirmation = null;
          _s.barcodeOpen = false;
        });
        _showToast('Could not parse food data');
      }
    }
  }

  void _cancelBarcodeLookup() {
    setState(() {
      _s.barcodePendingConfirmation = null;
      _s.barcodeScanning = true; // Resume scanning
    });
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
      final brandName = food['brand_name'] ?? '';
      final fullName = brandName.isNotEmpty ? '$brandName $name' : name;

      final description = food['food_description'] ?? food['description'] ?? '';

      // Parse nutrition from description (FatSecret format) OR from servings
      double cals = 0, protein = 0, fat = 0;

      // Try to get from servings first (barcode API format)
      final servings = food['servings'];
      if (servings != null && servings['serving'] != null) {
        final serving = servings['serving'];
        final firstServing = serving is List ? serving[0] : serving;

        if (firstServing != null) {
          cals =
              double.tryParse(firstServing['calories']?.toString() ?? '0') ?? 0;
          protein =
              double.tryParse(firstServing['protein']?.toString() ?? '0') ?? 0;
          fat = double.tryParse(firstServing['fat']?.toString() ?? '0') ?? 0;
        }
      }

      // Fallback: parse from description if servings didn't work
      if (cals == 0 && description.isNotEmpty) {
        final calMatch = RegExp(r'(\d+\.?\d*)\s*kcal').firstMatch(description);
        final proteinMatch = RegExp(
          r'Protein:\s*(\d+\.?\d*)g',
        ).firstMatch(description);
        final fatMatch = RegExp(r'Fat:\s*(\d+\.?\d*)g').firstMatch(description);

        if (calMatch != null) cals = double.tryParse(calMatch.group(1)!) ?? 0;
        if (proteinMatch != null) {
          protein = double.tryParse(proteinMatch.group(1)!) ?? 0;
        }
        if (fatMatch != null) {
          fat = double.tryParse(fatMatch.group(1)!) ?? 0;
        }
      }

      return FoodItem(
        name: fullName,
        desc: description,
        cals: cals,
        protein: protein,
        fat: fat,
        image:
            food['food_image']?.toString() ?? food['image']?.toString() ?? '',
      );
    } catch (e) {
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
        onOpenSearch: _openSearch,
        onCloseSearch: _closeSearch,
        onToggleBarcode: _toggleBarcode,
        onCloseBarcodeResult: _closeBarcodeResult,
        onAddBarcodeItem: _addBarcodeItemAndClose,
        onConfirmBarcode: _confirmBarcodeLookup,
        onCancelBarcode: _cancelBarcodeLookup,
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

class FoodItem {
  final String name;
  final String desc;
  final double cals;
  final double protein;
  final double fat;
  final String image;
  final String? impact;
  final Map<String, dynamic>? metadata;
  int portionIndex;

  FoodItem({
    required this.name,
    required this.desc,
    required this.cals,
    required this.protein,
    required this.fat,
    required this.image,
    this.impact,
    this.metadata,
    this.portionIndex = 1,
  });
}

class FoodSearchService {
  final Dio _dio;

  FoodSearchService([Dio? dio]) : _dio = dio ?? Dio();

  final List<FoodItem> catalog = [
    FoodItem(
      name: 'Ribeye Steak',
      desc: 'Grilled steak',
      cals: 700,
      protein: 62,
      fat: 48,
      image:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Blueberry Protein Bar',
      desc: 'Packaged Snack - 220 kcal',
      cals: 220,
      protein: 12,
      fat: 9,
      image:
          'https://images.unsplash.com/photo-1543339318-b43dc53e19e6?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Avocado Toast',
      desc: 'Breakfast - 320 kcal',
      cals: 320,
      protein: 8,
      fat: 20,
      image:
          'https://images.unsplash.com/photo-1551183053-1a9c2f2c4d04?auto=format&fit=crop&w=150&q=80',
    ),
  ];

  Future<List<FoodItem>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return List<FoodItem>.from(catalog);

    try {
      if (fatSecretAccessToken.isNotEmpty) {
        return await _searchFatSecret(q);
      }

      final response = await _dio.get(
        'https://www.themealdb.com/api/json/v1/1/search.php',
        queryParameters: {'s': q},
      );
      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null) {
        final first = q[0].toLowerCase();
        final resp = await _dio.get(
          'https://www.themealdb.com/api/json/v1/1/search.php',
          queryParameters: {'f': first},
        );
        final data2 = resp.data as Map<String, dynamic>;
        final meals2 = data2['meals'] as List<dynamic>?;
        if (meals2 != null && meals2.isNotEmpty) {
          final candidates = meals2.cast<Map<String, dynamic>>();
          final mapped = candidates
              .where(
                (meal) =>
                    _matchesByFuzzyWords(meal['strMeal'] as String? ?? '', q),
              )
              .map(
                (meal) => FoodItem(
                  name: meal['strMeal'] as String? ?? '',
                  desc: [
                    if ((meal['strCategory'] as String?)?.isNotEmpty ?? false)
                      meal['strCategory'] as String,
                    if ((meal['strArea'] as String?)?.isNotEmpty ?? false)
                      meal['strArea'] as String,
                  ].join(' • '),
                  cals: 0,
                  protein: 0,
                  fat: 0,
                  image: meal['strMealThumb'] as String? ?? '',
                  metadata: {'rawMeal': meal},
                ),
              )
              .toList();
          if (mapped.isNotEmpty) return mapped;
        }

        return _fuzzyLocalMatches(q);
      }

      final mapped = meals.cast<Map<String, dynamic>>().map((meal) {
        return FoodItem(
          name: meal['strMeal'] as String? ?? '',
          desc: [
            if ((meal['strCategory'] as String?)?.isNotEmpty ?? false)
              meal['strCategory'] as String,
            if ((meal['strArea'] as String?)?.isNotEmpty ?? false)
              meal['strArea'] as String,
          ].join(' • '),
          cals: 0,
          protein: 0,
          fat: 0,
          image: meal['strMealThumb'] as String? ?? '',
          metadata: {'rawMeal': meal},
        );
      }).toList();

      return mapped;
    } catch (e) {
      return _fuzzyLocalMatches(q);
    }
  }

  bool _matchesByFuzzyWords(String name, String query) {
    final words = name.toLowerCase().split(RegExp(r'\s+'));
    final q = query.toLowerCase();
    for (final w in words) {
      if (w.isEmpty) continue;
      final d = _levenshtein(w, q);
      if (d <= 1 || d <= (w.length * 0.2).ceil()) return true;
    }
    return false;
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);
    for (var i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  List<FoodItem> _fuzzyLocalMatches(String query) {
    final q = query.toLowerCase();
    final results = <FoodItem>[];
    for (final item in catalog) {
      final nameLower = item.name.toLowerCase();
      if (nameLower.contains(q)) {
        results.add(item);
        continue;
      }
      final words = nameLower.split(RegExp(r'\s+'));
      for (final w in words) {
        if (w.isEmpty) continue;
        final dist = _levenshtein(w, q);
        final sortedW = (w.split('')..sort()).join();
        final sortedQ = (q.split('')..sort()).join();
        if (dist <= 1 ||
            dist <= (w.length * 0.2).ceil() ||
            sortedW == sortedQ) {
          results.add(item);
          break;
        }
      }
    }
    return results;
  }

  Future<List<FoodItem>> _searchFatSecret(String query) async {
    if (fatSecretAccessToken.isEmpty) return [];
    try {
      final resp = await _dio.get(
        'https://platform.fatsecret.com/rest/server.api',
        queryParameters: {
          'method': 'foods.search',
          'search_expression': query,
          'format': 'json',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $fatSecretAccessToken'},
        ),
      );
      final data = resp.data as Map<String, dynamic>;
      final foods = data['foods'] != null
          ? data['foods']['food'] as List<dynamic>?
          : null;
      if (foods == null || foods.isEmpty) return [];
      final mapped = foods.cast<Map<String, dynamic>>().map((food) {
        final name =
            food['food_name'] as String? ?? food['name'] as String? ?? '';
        final foodId =
            food['food_id']?.toString() ?? food['id']?.toString() ?? '';
        final desc = food['food_type'] ?? '';
        return FoodItem(
          name: name,
          desc: desc,
          cals: 0,
          protein: 0,
          fat: 0,
          image: '',
          metadata: {
            'fatsecret_food': {'food_id': foodId, 'raw': food},
          },
        );
      }).toList();
      return mapped;
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchFatSecretByName(String name) async {
    if (fatSecretAccessToken.isEmpty) return null;
    try {
      final resp = await _dio.get(
        'https://platform.fatsecret.com/rest/server.api',
        queryParameters: {
          'method': 'foods.search',
          'search_expression': name,
          'format': 'json',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $fatSecretAccessToken'},
        ),
      );
      final data = resp.data as Map<String, dynamic>;
      final foods = data['foods'] != null
          ? data['foods']['food'] as List<dynamic>?
          : null;
      final first = foods != null && foods.isNotEmpty
          ? foods.first as Map<String, dynamic>
          : null;
      final foodId = first != null
          ? (first['food_id']?.toString() ?? first['id']?.toString())
          : null;
      if (foodId == null) return null;
      final det = await _dio.get(
        'https://platform.fatsecret.com/rest/server.api',
        queryParameters: {
          'method': 'food.get.v4',
          'food_id': foodId,
          'format': 'json',
          'include_food_attributes': 'true',
          'flag_default_serving': 'true',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $fatSecretAccessToken'},
        ),
      );
      final detData = det.data as Map<String, dynamic>;
      return detData['food'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}

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
        Consumer(
          builder: (context, ref, child) {
            final camInit = ref.watch(cameraInitProvider);
            return camInit.when(
              data: (_) {
                final cam = ref.read(cameraServiceProvider);
                if (cam.controller != null && cam.isInitialized) {
                  return CameraPreview(cam.controller!);
                }
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
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Code Detected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          barcodePendingConfirmation!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Look up this product?',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onCancelBarcode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onConfirmBarcode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667EEA),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Confirm'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (barcodeFound && barcodeFullData != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: LiquidGlassNutritionCard(
                  foodData: barcodeFullData!,
                  onAdd: barcodeItem != null
                      ? () => onAddBarcodeItem(barcodeItem!)
                      : () {},
                  onClose: onCloseBarcodeResult,
                ),
              ),
            ),
          ),
        CaptureQuickSwitch(
          open: false,
          onClose: () {},
          onDashboard: () => onNavigateFromQuick(const DashboardScreen()),
          onPlanner: () => onNavigateFromQuick(const PlannerScreen()),
          onAnalytics: () => onNavigateFromQuick(const AnalyticsScreen()),
          onSettings: () => onNavigateFromQuick(const SettingsScreen()),
        ),
        const Positioned(top: 40, right: 16, child: _PitchIndicator()),
      ],
    );
  }
}

class CaptureTopOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onQuickSwitch;
  final bool quickSwitchOpen;
  final VoidCallback onFlash;
  final VoidCallback onToggleOffline;
  final bool offlineMode;
  final VoidCallback onBarcode;

  const CaptureTopOverlay({
    super.key,
    required this.onClose,
    required this.onQuickSwitch,
    required this.quickSwitchOpen,
    required this.onFlash,
    required this.onToggleOffline,
    required this.offlineMode,
    required this.onBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x99000000), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CaptureIconButton(icon: Icons.close, onTap: onClose),
            Row(
              children: [
                CaptureIconButton(
                  icon: Icons.apps_rounded,
                  onTap: onQuickSwitch,
                  active: quickSwitchOpen,
                ),
                const SizedBox(width: 12),
                CaptureIconButton(icon: Icons.flash_on, onTap: onFlash),
                const SizedBox(width: 12),
                CaptureIconButton(
                  icon: offlineMode
                      ? Icons.signal_wifi_off
                      : Icons.signal_wifi_4_bar,
                  onTap: onToggleOffline,
                  active: offlineMode,
                ),
                const SizedBox(width: 12),
                CaptureIconButton(
                  icon: Icons.qr_code_scanner,
                  onTap: onBarcode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CaptureIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const CaptureIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? const Color(0xCCF59E0B) : const Color(0x33FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? AppColors.textMain : Colors.white),
      ),
    );
  }
}

class CaptureReticle extends ConsumerWidget {
  const CaptureReticle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchAsync = ref.watch(pitchProvider);

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.32,
      left: 0,
      right: 0,
      child: Center(
        child: pitchAsync.when(
          data: (deg) {
            final inRange = deg >= 40 && deg <= 50;
            final borderColor = inRange
                ? AppColors.accentGreen
                : Colors.white.withValues(alpha: 0.5);
            return Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 0,
                    spreadRadius: 1000,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.accentBlue,
                            width: 4,
                          ),
                          left: BorderSide(
                            color: AppColors.accentBlue,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.accentBlue,
                            width: 4,
                          ),
                          right: BorderSide(
                            color: AppColors.accentBlue,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: inRange
                              ? AppColors.accentGreen
                              : AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          inRange ? 'Aligned' : 'Hold 40–50°',
                          style: AppTextStyles.overline.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(
            width: 250,
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Container(
            width: 250,
            height: 250,
            color: Colors.black26,
            child: const Center(child: Text('Sensor unavailable')),
          ),
        ),
      ),
    );
  }
}

class CaptureOfflineBanner extends StatelessWidget {
  final bool visible;

  const CaptureOfflineBanner({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 110,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xDD0F172A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Offline mode. Uploads will queue.',
            style: AppTextStyles.labelSmall,
          ),
        ),
      ),
    );
  }
}

class CaptureBottomControls extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onShutterTap;

  const CaptureBottomControls({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onShutterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 40, top: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xCC000000), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _modeButton('scan'),
                const SizedBox(width: 24),
                _modeButton('search'),
                const SizedBox(width: 24),
                _modeButton('barcode'),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onShutterTap,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String value) {
    final isActive = mode == value;
    return GestureDetector(
      onTap: () => onModeChanged(value),
      child: Text(
        value.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class CaptureAnalysisSheet extends StatelessWidget {
  final bool open;
  final bool searchOpen;
  final List<FoodItem> items;
  final double totalCals;
  final double totalProtein;
  final double totalFat;
  final bool offlineMode;
  final VoidCallback onClose;
  final VoidCallback onOpenSearch;
  final void Function(int index) onRemoveItem;
  final void Function(int index, int portionIndex) onPortionChanged;
  final VoidCallback onLog;

  const CaptureAnalysisSheet({
    super.key,
    required this.open,
    required this.searchOpen,
    required this.items,
    required this.totalCals,
    required this.totalProtein,
    required this.totalFat,
    required this.offlineMode,
    required this.onClose,
    required this.onOpenSearch,
    required this.onRemoveItem,
    required this.onPortionChanged,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: open && !searchOpen ? 0 : -height,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgBody,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analysis',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textMain,
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Text(
                      'Edit',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  ...items.asMap().entries.map(
                    (entry) => FoodCard(
                      item: entry.value,
                      onRemove: () => onRemoveItem(entry.key),
                      onPortionChanged: (index) =>
                          onPortionChanged(entry.key, index),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onOpenSearch,
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: AppColors.accentBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Manual Search',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _macroTag('P: ${totalProtein.round()}g'),
                            const SizedBox(width: 8),
                            _macroTag('F: ${totalFat.round()}g'),
                          ],
                        ),
                        Text(
                          '${totalCals.round()} kcal',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onLog,
                    icon: const Icon(Icons.check),
                    label: Text(
                      offlineMode ? 'Save for Later' : 'Log to Diary',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentBlue),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onPortionChanged;

  const FoodCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onPortionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.desc,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                PortionSelector(
                  selectedIndex: item.portionIndex,
                  onChanged: onPortionChanged,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.remove_circle_outline,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

class PortionSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const PortionSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final slot = width / 3;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: slot * selectedIndex,
                top: 0,
                bottom: 0,
                child: Container(
                  width: slot,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textMain,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Row(
                children: [
                  _portionOption('Small', 0),
                  _portionOption('Med', 1),
                  _portionOption('Large', 2),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _portionOption(String label, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: Container(
          alignment: Alignment.center,
          height: 32,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class CaptureSearchOverlay extends StatelessWidget {
  final bool open;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClose;
  final VoidCallback onAddCaffeine;
  final VoidCallback onAddAlcohol;
  final List<FoodItem> results;
  final bool isSearching;
  final ValueChanged<FoodItem> onAddItem;
  final ValueChanged<FoodItem>? onTapItem;
  final VoidCallback onCreateCustom;

  const CaptureSearchOverlay({
    super.key,
    required this.open,
    required this.controller,
    required this.onQueryChanged,
    required this.onClose,
    required this.onAddCaffeine,
    required this.onAddAlcohol,
    required this.results,
    required this.isSearching,
    required this.onAddItem,
    this.onTapItem,
    required this.onCreateCustom,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: open ? 1 : 0,
      child: IgnorePointer(
        ignoring: !open,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: controller,
                        onChanged: onQueryChanged,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search foods',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _iconButton(Icons.close, onClose),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _impactChip(
                    'Caffeine',
                    const Color(0xFFF59E0B),
                    onAddCaffeine,
                  ),
                  const SizedBox(width: 8),
                  _impactChip('Alcohol', const Color(0xFF8B5CF6), onAddAlcohol),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : results.isNotEmpty
                    ? ListView(
                        children: results
                            .map(
                              (item) => SearchResultRow(
                                item: item,
                                onAdd: () => onAddItem(item),
                                onTap: onTapItem == null
                                    ? null
                                    : () => onTapItem!(item),
                              ),
                            )
                            .toList(),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No results found.',
                              style: AppTextStyles.overline,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: onCreateCustom,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textMain,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Create Custom Food',
                                style: AppTextStyles.overline,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _impactChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: AppColors.textMain),
      ),
    );
  }
}

class SearchResultRow extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  const SearchResultRow({
    super.key,
    required this.item,
    required this.onAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (item.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.desc,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Add',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CaptureBarcodeOverlay extends StatefulWidget {
  final bool open;
  final bool found;
  final bool scanning;
  final FoodItem? item;
  final VoidCallback? onAdd;
  final VoidCallback onClose;
  final VoidCallback onNotFound;
  final void Function(BarcodeCapture)? onBarcodeDetected;

  const CaptureBarcodeOverlay({
    super.key,
    required this.open,
    required this.found,
    required this.scanning,
    required this.item,
    required this.onAdd,
    required this.onClose,
    required this.onNotFound,
    this.onBarcodeDetected,
  });

  @override
  State<CaptureBarcodeOverlay> createState() => _CaptureBarcodeOverlayState();
}

class _CaptureBarcodeOverlayState extends State<CaptureBarcodeOverlay> {
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.open && widget.scanning) {
      _initializeScanner();
    }
  }

  @override
  void didUpdateWidget(CaptureBarcodeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open && !oldWidget.open) {
      _initializeScanner();
    } else if (!widget.open && oldWidget.open) {
      _disposeScanner();
    } else if (widget.open && widget.scanning && !oldWidget.scanning) {
      _initializeScanner();
    } else if (widget.open && !widget.scanning && oldWidget.scanning) {
      _disposeScanner();
    }
  }

  @override
  void dispose() {
    _disposeScanner();
    super.dispose();
  }

  void _initializeScanner() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: [BarcodeFormat.all],
    );
  }

  void _disposeScanner() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.scanning && _controller != null)
            Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (widget.onBarcodeDetected != null) {
                    widget.onBarcodeDetected!(capture);
                  }
                },
              ),
            )
          else
            Container(
              width: 240,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            widget.found
                ? 'Code detected'
                : widget.scanning
                ? 'Scan barcode or QR code...'
                : 'Looking up...',
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          if (widget.found && widget.item != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    widget.item!.name,
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.item!.cals} kcal - ${widget.item!.protein}g Protein - ${widget.item!.fat}g Fat',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: widget.onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textMain,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Item',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onNotFound,
            child: Text(
              'Barcode not found',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: AppColors.textMain,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Close',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CaptureQuickSwitch extends StatelessWidget {
  final bool open;
  final VoidCallback onClose;
  final VoidCallback onDashboard;
  final VoidCallback onPlanner;
  final VoidCallback onAnalytics;
  final VoidCallback onSettings;

  const CaptureQuickSwitch({
    super.key,
    required this.open,
    required this.onClose,
    required this.onDashboard,
    required this.onPlanner,
    required this.onAnalytics,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (!open) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quick Switch', style: AppTextStyles.titleMedium),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 260,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: [
                          QuickTile(
                            icon: Icons.home_filled,
                            label: 'Dashboard',
                            onTap: onDashboard,
                          ),
                          QuickTile(
                            icon: Icons.calendar_month,
                            label: 'Planner',
                            onTap: onPlanner,
                          ),
                          QuickTile(
                            icon: Icons.bar_chart,
                            label: 'Analytics',
                            onTap: onAnalytics,
                          ),
                          QuickTile(
                            icon: Icons.person_outline,
                            label: 'Settings',
                            onTap: onSettings,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accentBlue, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidGlassNutritionCard extends StatelessWidget {
  final Map<String, dynamic> foodData;
  final VoidCallback onAdd;
  final VoidCallback onClose;

  const LiquidGlassNutritionCard({
    super.key,
    required this.foodData,
    required this.onAdd,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final food = foodData;
    final servings = food['servings']?['serving'] as List?;
    final primaryServing = servings?.first ?? {};

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (food['brand_name'] != null)
                            Text(
                              food['brand_name'],
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            food['food_name'] ?? 'Unknown Product',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (food['food_type'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                food['food_type'],
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (primaryServing.isNotEmpty) ...[
                      _buildGlassContainer(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Serving Size',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white60,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    primaryServing['serving_description'] ??
                                        'N/A',
                                    style: AppTextStyles.label.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Nutrition Facts',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGlassContainer(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.3),
                          Colors.deepOrange.withValues(alpha: 0.2),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CALORIES',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  '${primaryServing['calories'] ?? 0}',
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'kcal',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroCard(
                            'Protein',
                            primaryServing['protein'] ?? 0,
                            'g',
                            Icons.fitness_center,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMacroCard(
                            'Carbs',
                            primaryServing['carbohydrate'] ?? 0,
                            'g',
                            Icons.grain,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMacroCard(
                            'Fat',
                            primaryServing['fat'] ?? 0,
                            'g',
                            Icons.water_drop,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Detailed Breakdown',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGlassContainer(
                      child: Column(
                        children: _buildAllNutrients(context, primaryServing),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF667EEA,
                            ).withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add to My Foods',
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, Gradient? gradient}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient:
                gradient ??
                LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildMacroCard(
    String label,
    dynamic value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return _buildGlassContainer(
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value ?? 0}$unit',
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, dynamic value, String unit) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Text(
            '$value$unit',
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllNutrients(
    BuildContext context,
    Map<String, dynamic> serving,
  ) {
    final List<Widget> widgets = [];

    final excludeKeys = {
      'calories',
      'protein',
      'carbohydrate',
      'fat',
      'serving_description',
      'serving_id',
      'serving_url',
      'number_of_units',
    };

    serving.forEach((key, value) {
      if (excludeKeys.contains(key)) return;

      final label = key
          .split('_')
          .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w,
          )
          .join(' ');

      String displayValue;
      if (value == null) {
        displayValue = '';
      } else if (value is List) {
        displayValue = 'List (${value.length})';
      } else if (value is Map) {
        displayValue = 'Object';
      } else {
        displayValue = value.toString();
      }

      widgets.add(_buildNutrientRow(label, displayValue, ''));
    });

    return widgets.isEmpty
        ? [
            const Text(
              'No detailed nutrition data available',
              style: TextStyle(color: Colors.white70),
            ),
          ]
        : widgets;
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

Future<void> showLogDialog(
  BuildContext context, {
  required VoidCallback onViewDiary,
  required VoidCallback onClose,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Meal Logged', style: AppTextStyles.dmSans16Bold),
            const SizedBox(height: 12),
            Text(
              'Your meal was added to the diary.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onViewDiary();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('View Diary', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onClose();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: AppColors.textMain,
                    ),
                    child: Text('Back Home', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<FoodItem?> showCustomFoodDialog(
  BuildContext context, {
  String initialName = '',
}) {
  final nameController = TextEditingController(text: initialName);
  final calController = TextEditingController();
  final proteinController = TextEditingController();
  final fatController = TextEditingController();

  return showDialog<FoodItem>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Custom Food',
                      style: AppTextStyles.dmSans16Bold,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _modalInput('Name', nameController),
                _modalInput(
                  'Calories',
                  calController,
                  keyboard: TextInputType.number,
                ),
                _modalInput(
                  'Protein',
                  proteinController,
                  keyboard: TextInputType.number,
                ),
                _modalInput(
                  'Fat',
                  fatController,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final calories =
                              double.tryParse(calController.text) ?? 0;
                          if (name.isEmpty || calories <= 0) return;
                          final custom = FoodItem(
                            name: name,
                            desc: 'Custom - ${calories.round()} kcal',
                            cals: calories,
                            protein:
                                double.tryParse(proteinController.text) ?? 0,
                            fat: double.tryParse(fatController.text) ?? 0,
                            image:
                                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=150&q=80',
                          );
                          Navigator.pop(context, custom);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textMain,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Save', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: AppColors.textMain,
                        ),
                        child: Text('Cancel', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Widget _modalInput(
  String label,
  TextEditingController controller, {
  TextInputType keyboard = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    ),
  );
}

class MealDetailModal extends StatefulWidget {
  final FoodItem item;
  final Future<Map<String, dynamic>?> Function(String) loadFatSecret;

  const MealDetailModal({
    super.key,
    required this.item,
    required this.loadFatSecret,
  });

  @override
  State<MealDetailModal> createState() => _MealDetailModalState();
}

class _MealDetailModalState extends State<MealDetailModal> {
  Map<String, dynamic>? fatRaw;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final raw = widget.item.metadata?['rawMeal'] as Map<String, dynamic>?;

    return AlertDialog(
      title: Text(widget.item.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item.image.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 160,
                child: Image.network(widget.item.image, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),
            if (raw != null) ...[
              Text(
                'Category: ${raw['strCategory'] ?? '-'}',
                style: AppTextStyles.overline,
              ),
              const SizedBox(height: 4),
              Text(
                'Area: ${raw['strArea'] ?? '-'}',
                style: AppTextStyles.overline,
              ),
              const SizedBox(height: 8),
              Text('Instructions', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(raw['strInstructions'] ?? '-', style: AppTextStyles.body),
              const SizedBox(height: 12),
            ],
            if (fatRaw != null) ...[_buildFatSecretSection(fatRaw!)],
            if (fatRaw == null && !loading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => loading = true);
                    final f = await widget.loadFatSecret(widget.item.name);
                    setState(() {
                      fatRaw = f;
                      loading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Load Nutrition Details'),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(widget.item);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildFatSecretSection(Map<String, dynamic> fat) {
    final servings = fat['servings'] != null
        ? fat['servings']['serving'] as List
        : null;
    final attrs = fat['food_attributes'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('Nutrition Facts', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        if (servings != null && servings.isNotEmpty) ...[
          Text(
            'Serving: ${servings[0]['serving_description'] ?? '-'}',
            style: AppTextStyles.overline,
          ),
          const SizedBox(height: 8),
          Text(
            'Calories: ${servings[0]['calories'] ?? '-'} kcal',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
        ],
        if (attrs != null) ...[
          Text('Attributes', style: AppTextStyles.label),
          const SizedBox(height: 6),
          if (attrs['allergens'] != null &&
              attrs['allergens']['allergen'] != null)
            Wrap(
              spacing: 8,
              children: List<Widget>.from(
                (attrs['allergens']['allergen'] as List).map((a) {
                  final name = a['name'] ?? '';
                  final value = a['value'] ?? '0';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (value == '0')
                          ? const Color(0xFFDFF7E0)
                          : const Color(0xFFFFEDEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (value == '0') ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: (value == '0') ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(name, style: AppTextStyles.labelSmall),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ],
    );
  }
}
