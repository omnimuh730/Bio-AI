import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:camera/camera.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:bio_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/ui/pages/capture/models/food_item.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_analysis_sheet.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_barcode_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_bottom_controls.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_offline_banner.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_quick_switch.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_reticle.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_search_overlay.dart';
import 'package:bio_ai/ui/pages/capture/widgets/capture_top_overlay.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bio_ai/core/config.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _sheetOpen = false;
  bool _searchOpen = false;
  bool _offlineMode = false;
  bool _barcodeOpen = false;
  bool _barcodeFound = false;
  bool _quickSwitchOpen = false;
  bool _flashOn = false;
  bool _isCapturing = false;

  String _mode = 'scan';
  final List<double> _portionOptions = [0.75, 1.0, 1.5];
  final List<FoodItem> _items = [];
  List<FoodItem> _results = [];

  Timer? _barcodeTimer;
  final Dio _dio = Dio();
  Timer? _searchDebounce;
  bool _searching = false;

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
    FoodItem(
      name: 'Ribeye Steak',
      desc: 'High Protein - Iron Rich - 850 kcal',
      cals: 850,
      protein: 62,
      fat: 48,
      image:
          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Protein Smoothie',
      desc: 'Whey - Banana - 260 kcal',
      cals: 260,
      protein: 24,
      fat: 4,
      image:
          'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Oatmeal and Berries',
      desc: 'Fiber Boost - 320 kcal',
      cals: 320,
      protein: 12,
      fat: 6,
      image:
          'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Avocado Toast',
      desc: 'Healthy Fats - 280 kcal',
      cals: 280,
      protein: 8,
      fat: 14,
      image:
          'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Greek Yogurt Bowl',
      desc: 'Probiotic - 210 kcal',
      cals: 210,
      protein: 18,
      fat: 4,
      image:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Salmon Power Bowl',
      desc: 'Omega 3 - 520 kcal',
      cals: 520,
      protein: 34,
      fat: 18,
      image:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=150&q=80',
    ),
  ];

  final FoodItem _barcodeItem = FoodItem(
    name: 'Blueberry Protein Bar',
    desc: 'Packaged Snack - 220 kcal',
    cals: 220,
    protein: 12,
    fat: 9,
    image:
        'https://images.unsplash.com/photo-1543339318-b43dc53e19e6?auto=format&fit=crop&w=150&q=80',
  );

  @override
  void initState() {
    super.initState();
    _items.add(_catalog.firstWhere((item) => item.name == 'Ribeye Steak'));
    _results = List<FoodItem>.from(_catalog);

    // Initialize camera asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCamera());
  }

  Future<void> _initCamera() async {
    try {
      final camera = ref.read(cameraServiceProvider);
      await camera.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      // ignore errors here; fallback to static image
    }
  }

  @override
  void dispose() {
    _barcodeTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    // Dispose camera controller when leaving the screen
    try {
      ref.read(cameraServiceProvider).dispose();
    } catch (_) {}
    super.dispose();
  }

  void _openSheet() => setState(() => _sheetOpen = true);

  void _closeSheet() => setState(() => _sheetOpen = false);

  void _openSearch() {
    setState(() {
      _searchOpen = true;
      _mode = 'search';
    });
  }

  void _closeSearch() => setState(() {
    _searchOpen = false;
    _mode = 'scan';
  });

  void _toggleOffline() => setState(() => _offlineMode = !_offlineMode);

  void _toggleQuickSwitch() =>
      setState(() => _quickSwitchOpen = !_quickSwitchOpen);

  void _toggleBarcode() {
    setState(() {
      _barcodeOpen = !_barcodeOpen;
      _barcodeFound = false;
    });
    _barcodeTimer?.cancel();
    if (_barcodeOpen) {
      _barcodeTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _barcodeFound = true);
        }
      });
    }
  }

  void _addItem(FoodItem item) {
    setState(() => _items.add(item));
    _openSheet();
    _showToast('Added ${item.name}');
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    _showToast('Item removed');
  }

  void _filterSearch(String query) {
    _searchDebounce?.cancel();
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = List<FoodItem>.from(_catalog);
        _searching = false;
      });
      return;
    }

    final lower = q.toLowerCase();
    setState(() {
      _results = _catalog
          .where((item) => item.name.toLowerCase().contains(lower))
          .toList();
      _searching = true;
    });

    _searchDebounce = Timer(const Duration(seconds: 1), () async {
      await _searchMeals(q);
    });
  }

  Future<void> _searchFatSecret(String query) async {
    try {
      final response = await _dio.get(
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
      final data = response.data as Map<String, dynamic>;
      final foods = data['foods'] != null
          ? data['foods']['food'] as List<dynamic>?
          : null;
      if (foods == null) {
        setState(() {
          _results = [];
          _searching = false;
        });
        return;
      }
      final mapped = foods.map((f) {
        final food = f as Map<String, dynamic>;
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
      setState(() {
        _results = mapped;
        _searching = false;
      });
    } catch (e) {
      setState(() {
        _results = [];
        _searching = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchFatSecretByName(String name) async {
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
      final first = foods != null && foods.isNotEmpty ? foods.first : null;
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
      final food = detData['food'] as Map<String, dynamic>?;
      return food;
    } catch (e) {
      return null;
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  // Small Levenshtein implementation used for basic fuzzy matching (typo tolerance)
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
      for (var j = 0; j < v0.length; j++) v0[j] = v1[j];
    }
    return v1[t.length];
  }

  List<FoodItem> _fuzzyLocalMatches(String query) {
    final q = query.toLowerCase();
    final results = <FoodItem>[];
    for (final item in _catalog) {
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

  Future<void> _searchMeals(String query) async {
    try {
      // Prefer FatSecret if token present
      if (fatSecretAccessToken.isNotEmpty) {
        await _searchFatSecret(query);
        return;
      }

      final response = await _dio.get(
        'https://www.themealdb.com/api/json/v1/1/search.php',
        queryParameters: {'s': query},
      );
      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null) {
        // Remote returned no exact matches. Try a first-letter broad search and fuzzy-filter results from remote.
        print('No exact meals found for "$query"; trying first-letter search');
        final first = query.isNotEmpty ? query[0].toLowerCase() : '';
        if (first.isNotEmpty) {
          try {
            final resp2 = await _dio.get(
              'https://www.themealdb.com/api/json/v1/1/search.php',
              queryParameters: {'f': first},
            );
            final data2 = resp2.data as Map<String, dynamic>;
            final meals2 = data2['meals'] as List<dynamic>?;
            if (meals2 != null) {
              final candidates = meals2
                  .map((m) => m as Map<String, dynamic>)
                  .where((meal) {
                    final name = (meal['strMeal'] as String? ?? '')
                        .toLowerCase();
                    // fuzzy by word distance
                    final words = name.split(RegExp(r'\s+'));
                    for (final w in words) {
                      if (w.isEmpty) continue;
                      final dist = _levenshtein(w, query.toLowerCase());
                      if (dist <= 1 || dist <= (w.length * 0.2).ceil())
                        return true;
                    }
                    return false;
                  })
                  .toList();
              if (candidates.isNotEmpty) {
                final mapped2 = candidates.map((meal) {
                  final name = meal['strMeal'] as String? ?? '';
                  final thumb = meal['strMealThumb'] as String? ?? '';
                  final category = meal['strCategory'] as String? ?? '';
                  final area = meal['strArea'] as String? ?? '';
                  final desc = [
                    if (category.isNotEmpty) category,
                    if (area.isNotEmpty) area,
                  ].join(' • ');
                  return FoodItem(
                    name: name,
                    desc: desc,
                    cals: 0,
                    protein: 0,
                    fat: 0,
                    image: thumb,
                    metadata: {'rawMeal': meal},
                  );
                }).toList();
                setState(() {
                  _results = mapped2;
                  _searching = false;
                });
                return;
              }
            }
          } catch (_) {}
        }

        // fallback to fuzzy local matches when remote fails
        final fallback = _fuzzyLocalMatches(query);
        setState(() {
          _results = fallback;
          _searching = false;
        });
        return;
      }
      final mapped = meals.map((m) {
        final meal = m as Map<String, dynamic>;
        final name = meal['strMeal'] as String? ?? '';
        final thumb = meal['strMealThumb'] as String? ?? '';
        final category = meal['strCategory'] as String? ?? '';
        final area = meal['strArea'] as String? ?? '';
        final desc = [
          if (category.isNotEmpty) category,
          if (area.isNotEmpty) area,
        ].join(' • ');
        return FoodItem(
          name: name,
          desc: desc,
          cals: 0,
          protein: 0,
          fat: 0,
          image: thumb,
          metadata: {'rawMeal': meal},
        );
      }).toList();
      setState(() {
        _results = mapped;
        _searching = false;
      });
    } catch (e, st) {
      print('Error searching meals: $e\n$st');
      final fallback = _fuzzyLocalMatches(query);
      setState(() {
        _results = fallback;
        _searching = false;
      });
    }
  }

  void _openMealModal(FoodItem item) {
    final raw = item.metadata?['rawMeal'] as Map<String, dynamic>?;
    final fatRaw = item.metadata?['fatsecret_food'] as Map<String, dynamic>?;

    final tagsRaw = (raw?['strTags'] as String?) ?? '';
    final List<String> tags = tagsRaw.isEmpty
        ? []
        : tagsRaw
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

    final youtube = (raw?['strYoutube'] as String?) ?? '';
    final ytId = youtube.isNotEmpty ? _youtubeIdFromUrl(youtube) : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(item.name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.image.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.image),
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
                  ],
                  if (tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(t, style: AppTextStyles.overline),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (raw != null) ...[
                    Text('Instructions', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      raw['strInstructions'] ?? '-',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 12),
                    if (ytId != null) ...[
                      GestureDetector(
                        onTap: () => _openUrl(youtube),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    'https://img.youtube.com/vi/$ytId/hqdefault.jpg',
                                    width: 120,
                                    height: 74,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Watch video tutorial',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],

                  if (fatRaw != null) ...[
                    const Divider(),
                    Text('Nutrition Facts', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    if (fatRaw['servings'] != null &&
                        fatRaw['servings']['serving'] != null) ...[
                      Text(
                        'Serving: ${fatRaw['servings']['serving'][0]['serving_description'] ?? '-'}',
                        style: AppTextStyles.overline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calories: ${fatRaw['servings']['serving'][0]['calories'] ?? '-'} kcal',
                        style: AppTextStyles.label,
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (fatRaw['food_attributes'] != null) ...[
                      Text('Attributes', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      if (fatRaw['food_attributes']['allergens'] != null &&
                          fatRaw['food_attributes']['allergens']['allergen'] !=
                              null)
                        Wrap(
                          spacing: 8,
                          children: List<Widget>.from(
                            (fatRaw['food_attributes']['allergens']['allergen']
                                    as List)
                                .map((a) {
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
                                          (value == '0')
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          size: 14,
                                          color: (value == '0')
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          name,
                                          style: AppTextStyles.labelSmall,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ],
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
                  _addItem(item);
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
              if (fatRaw == null && fatSecretAccessToken.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final f = await _fetchFatSecretByName(item.name);
                    if (f != null) {
                      setState(() {
                        item.metadata?['fatsecret_food'] = f;
                      });
                    } else {
                      _showToast('FatSecret details not found');
                    }
                  },
                  child: const Text('Load FatSecret details'),
                ),
            ],
          );
        },
      ),
    );
  }

  String? _youtubeIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('v')) return uri.queryParameters['v'];
      if (uri.pathSegments.isNotEmpty) return uri.pathSegments.last;
    } catch (_) {}
    return null;
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showToast('Could not open link');
      }
    } catch (e) {
      _showToast('Could not open link');
    }
  }

  double get _totalCals {
    double total = 0;
    for (final item in _items) {
      total += item.cals * _portionOptions[item.portionIndex];
    }
    return total;
  }

  double get _totalProtein {
    double total = 0;
    for (final item in _items) {
      total += item.protein * _portionOptions[item.portionIndex];
    }
    return total;
  }

  double get _totalFat {
    double total = 0;
    for (final item in _items) {
      total += item.fat * _portionOptions[item.portionIndex];
    }
    return total;
  }

  Future<void> _captureAndAnalyze() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final camera = ref.read(cameraServiceProvider);
      final vision = ref.read(visionRepositoryProvider);
      final file = await camera.takePhoto();
      if (_offlineMode) {
        await vision.queuePhoto(file, meta: {'source': 'camera'});
        _showToast('Saved offline. Upload queued.');
        _openSheet();
      } else {
        // Upload and pretend we got a result back from the ML service
        await vision.uploadPhoto(file, meta: {'source': 'camera'});
        // Simulate an analysis result by adding a catalog item
        _addItem(_catalog[2]);
        _showToast('Analysis complete');
      }
    } catch (e) {
      _showToast('Capture failed: $e');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _toggleFlash() async {
    final torch = ref.read(torchServiceProvider);
    setState(() => _flashOn = !_flashOn);
    try {
      if (_flashOn) {
        await torch.turnOn();
      } else {
        await torch.turnOff();
      }
    } catch (e) {
      _showToast('Flash unavailable');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraView(),
          CaptureTopOverlay(
            onClose: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            ),
            onQuickSwitch: _toggleQuickSwitch,
            quickSwitchOpen: _quickSwitchOpen,
            onFlash: _toggleFlash,
            onToggleOffline: _toggleOffline,
            offlineMode: _offlineMode,
            onBarcode: _toggleBarcode,
          ),
          const CaptureReticle(),
          CaptureOfflineBanner(visible: _offlineMode),
          CaptureBottomControls(
            mode: _mode,
            onModeChanged: (mode) {
              setState(() => _mode = mode);
              if (mode == 'search') {
                _openSearch();
              }
            },
            onShutterTap: () {
              if (_mode == 'search') {
                _openSearch();
                return;
              }
              if (_mode == 'barcode') {
                _toggleBarcode();
                return;
              }
              _captureAndAnalyze();
            },
          ),
          if (_sheetOpen && !_searchOpen) _buildSheetBackdrop(),
          CaptureAnalysisSheet(
            open: _sheetOpen,
            searchOpen: _searchOpen,
            items: _items,
            totalCals: _totalCals,
            totalProtein: _totalProtein,
            totalFat: _totalFat,
            offlineMode: _offlineMode,
            onClose: _closeSheet,
            onOpenSearch: _openSearch,
            onRemoveItem: _removeItem,
            onPortionChanged: (index, portion) {
              setState(() => _items[index].portionIndex = portion);
            },
            onLog: () {
              if (_offlineMode) {
                _showToast('Saved offline. Upload queued.');
                _closeSheet();
                return;
              }
              _openLogModal();
            },
          ),
          CaptureSearchOverlay(
            open: _searchOpen,
            controller: _searchController,
            onQueryChanged: _filterSearch,
            onClose: _closeSearch,
            onAddCaffeine: () => _addItem(_catalog[0]),
            onAddAlcohol: () => _addItem(_catalog[1]),
            results: _results,
            isSearching: _searching,
            onAddItem: (item) => _addItem(item),
            onTapItem: (item) => _openMealModal(item),
            onCreateCustom: _openCustomFood,
          ),
          CaptureBarcodeOverlay(
            open: _barcodeOpen,
            found: _barcodeFound,
            item: _barcodeItem,
            onAdd: () {
              _addItem(_barcodeItem);
              _toggleBarcode();
            },
            onClose: _toggleBarcode,
            onNotFound: () => _showToast('Barcode not found'),
          ),
          CaptureQuickSwitch(
            open: _quickSwitchOpen,
            onClose: _toggleQuickSwitch,
            onDashboard: () => _navigateFromQuick(const DashboardScreen()),
            onPlanner: () => _navigateFromQuick(const PlannerScreen()),
            onAnalytics: () => _navigateFromQuick(const AnalyticsScreen()),
            onSettings: () => _navigateFromQuick(const SettingsScreen()),
          ),

          // Small debug / guidance overlay showing device pitch (gyro)
          Positioned(
            top: 40,
            right: 16,
            child: Consumer(
              builder: (context, ref, _) {
                final pitchAsync = ref.watch(pitchProvider);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
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
                    error: (e, st) => const Text(
                      'Pitch: —',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isCapturing)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSheetBackdrop() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeSheet,
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildCameraView() {
    final camera = ref.read(cameraServiceProvider);
    if (camera.isInitialized && camera.controller != null) {
      // Show a live camera preview when available
      return SizedBox.expand(child: CameraPreview(camera.controller!));
    }

    // Fallback: show a static background image
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
  }

  void _navigateFromQuick(Widget screen) {
    _toggleQuickSwitch();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _openLogModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnalyticsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('View Diary', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _closeSheet();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: AppColors.textMain,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Back Home', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCustomFood() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(
          text: _searchController.text,
        );
        final calController = TextEditingController();
        final proteinController = TextEditingController();
        final fatController = TextEditingController();
        bool isPublic = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
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
                    Row(
                      children: [
                        Checkbox(
                          value: isPublic,
                          onChanged: (value) =>
                              setModalState(() => isPublic = value ?? false),
                          activeColor: AppColors.accentBlue,
                        ),
                        Text(
                          'Add to public database',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
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
                              if (name.isEmpty || calories <= 0) {
                                _showToast('Name and calories required');
                                return;
                              }
                              final custom = FoodItem(
                                name: name,
                                desc:
                                    '${isPublic ? 'Public' : 'Personal'} - ${calories.round()} kcal',
                                cals: calories,
                                protein:
                                    double.tryParse(proteinController.text) ??
                                    0,
                                fat: double.tryParse(fatController.text) ?? 0,
                                image:
                                    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=150&q=80',
                              );
                              Navigator.pop(context);
                              _addItem(custom);
                              _searchController.clear();
                              _filterSearch('');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textMain,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Cancel', style: AppTextStyles.button),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
}
