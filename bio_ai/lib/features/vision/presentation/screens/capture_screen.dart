import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
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
  }

  @override
  void dispose() {
    _barcodeTimer?.cancel();
    _searchController.dispose();
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
    final lower = query.toLowerCase();
    setState(() {
      _results = _catalog
          .where((item) => item.name.toLowerCase().contains(lower))
          .toList();
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
      ),
    );
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
            onAddItem: (item) => _addItem(item),
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
