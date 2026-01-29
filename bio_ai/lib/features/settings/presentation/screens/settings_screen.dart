import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/vision/presentation/screens/capture_screen.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';
import 'package:bio_ai/ui/pages/settings/models/device_state.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_account_section.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_device_section.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_dietary_section.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_goal_section.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_modal_shell.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_plan_options.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_preference_section.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_profile_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Map<String, DeviceState> _devices = {
    'apple': DeviceState('Apple Health', true, '2m ago'),
    'google': DeviceState('Google Fit', false, ''),
    'garmin': DeviceState('Garmin', false, ''),
    'fitbit': DeviceState('Fitbit', true, '12m ago'),
  };

  bool _metricUnits = true;
  String _selectedPlan = 'pro-monthly';
  String _selectedGoal = 'Lose Fat';
  final TextEditingController _deleteController = TextEditingController();
  bool _notificationsOn = true;
  bool _offlineOn = false;

  // Bluetooth permission status cache
  PermissionStatus? _btPermissionStatus;

  @override
  void initState() {
    super.initState();
    // Check Bluetooth permission status once the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateBtPermission());
  }

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == 3) {
      return;
    }
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlannerScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
  }

  void _onFabTapped() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CaptureScreen()),
    );
  }

  void _toggleDevice(String key) {
    setState(() {
      final device = _devices[key];
      if (device == null) {
        return;
      }
      device.connected = !device.connected;
      device.lastSync = device.connected ? 'just now' : '';
    });
    _showToast(
      '${_devices[key]?.label} ${_devices[key]?.connected == true ? 'connected' : 'disconnected'}',
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBody,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SettingsProfileHeader(),
                SettingsDeviceSection(
                  devices: _devices,
                  onToggle: _toggleDevice,
                  onResync: () => _showToast('Resyncing devices...'),
                  onReauth: () => _showToast('Re-auth requested'),
                  onFind: _openFindDevicesModal,
                ),
                SettingsDietarySection(
                  onChipTap: (chip) => _showToast('$chip selected'),
                ),
                SettingsPreferenceSection(
                  metricUnits: _metricUnits,
                  onMetricChanged: (value) =>
                      setState(() => _metricUnits = value),
                  notificationsOn: _notificationsOn,
                  onNotificationsChanged: (value) =>
                      setState(() => _notificationsOn = value),
                  offlineOn: _offlineOn,
                  onOfflineChanged: (value) =>
                      setState(() => _offlineOn = value),
                ),
                SettingsGoalSection(
                  goals: [
                    SettingsGoalItem(
                      title: 'Lose Fat',
                      selected: _selectedGoal == 'Lose Fat',
                    ),
                    SettingsGoalItem(
                      title: 'Build Muscle',
                      selected: _selectedGoal == 'Build Muscle',
                    ),
                    SettingsGoalItem(
                      title: 'Maintain & Cognitive',
                      selected: _selectedGoal == 'Maintain & Cognitive',
                    ),
                  ],
                  onGoalTap: (title) {
                    setState(() => _selectedGoal = title);
                    _showToast('$title selected');
                  },
                ),
                SettingsAccountSection(
                  onOnboarding: () => _showToast('Onboarding'),
                  onManageSubscription: _openSubscriptionModal,
                  onExportData: _openExportModal,
                  onDeleteAccount: _openDeleteModal,
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagnostics',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: _testTorch,
                            child: const Text('Torch'),
                          ),
                          ElevatedButton(
                            onPressed: _testGps,
                            child: const Text('GPS'),
                          ),
                          ElevatedButton(
                            onPressed: _testNetwork,
                            child: const Text('Network'),
                          ),
                          Chip(
                            label: Text('Bluetooth: ${_btPermissionLabel()}'),
                          ),
                          ElevatedButton(
                            onPressed: _openFindDevicesModal,
                            child: const Text('Show Devices'),
                          ),
                          TextButton(
                            onPressed: _requestBluetoothPermission,
                            child: const Text('Request Permission'),
                          ),
                          ElevatedButton(
                            onPressed: _testCapture,
                            child: const Text('Capture'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Connected Devices',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  tooltip: 'Refresh',
                                  onPressed: () async {
                                    await _updateBtPermission();
                                    ref.invalidate(
                                      connectedDeviceSummariesProvider,
                                    );
                                    _showToast('Refreshing devices...');
                                  },
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Consumer(
                              builder: (context, ref, _) {
                                final devicesAsync = ref.watch(
                                  connectedDeviceSummariesProvider,
                                );
                                return devicesAsync.when(
                                  data: (list) {
                                    if (list.isEmpty) {
                                      return Text(
                                        'No connected devices',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: list
                                          .map(
                                            (d) => ListTile(
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(
                                                d['name'] ?? 'Unknown',
                                              ),
                                              subtitle: Text(d['id'] ?? '-'),
                                              onTap: () => _showToast(
                                                '${d['name'] ?? d['id']} selected',
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    );
                                  },
                                  loading: () => const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  error: (e, st) => Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Unable to load devices: ${e.toString()}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _requestBluetoothPermission,
                                        child: const Text('Request Permission'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingNavBar(
                selectedIndex: 3,
                onItemTapped: _onNavTapped,
                onFabTapped: _onFabTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSubscriptionModal() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SettingsModalShell(
              title: 'Subscription',
              primaryText: 'Apply Plan',
              onPrimary: () {
                Navigator.pop(context);
                _showToast('Plan updated to ${_planLabel(_selectedPlan)}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose Plan'),
                  SettingsPlanOptions(
                    selectedPlan: _selectedPlan,
                    onPlanSelected: (plan) =>
                        setModalState(() => _selectedPlan = plan),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openExportModal() {
    showDialog(
      context: context,
      builder: (context) => SettingsModalShell(
        title: 'Export Data',
        primaryText: 'Export',
        onPrimary: () {
          Navigator.pop(context);
          _showToast('Export started');
        },
        child: const Text('We will export anonymized data...'),
      ),
    );
  }

  Future<void> _openFindDevicesModal() async {
    if (!mounted) return;
    _showToast('Checking Bluetooth permissions...');
    try {
      final ble = ref.read(bleServiceProvider);
      final ok = await ble.ensurePermissions();

      await _updateBtPermission();
      if (!mounted) return;

      if (!ok) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bluetooth permission required'),
            content: const Text(
              'This action requires Bluetooth access. Please enable Bluetooth permissions in system settings and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;
      _showToast('Fetching connected Bluetooth devices...');

      final supported = await ble.isSupported();
      if (!mounted) return;

      if (!supported) {
        if (mounted) {
          _showToast('Bluetooth not supported on this device');
        }
        return;
      }

      final devices = await ble.connectedDeviceSummaries();
      if (!mounted) return;

      if (devices.isEmpty) {
        if (mounted) {
          _showToast('No connected devices found');
        }
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connected devices'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: devices
                  .map(
                    (d) => ListTile(
                      title: Text(d['name'] ?? 'Unknown'),
                      subtitle: Text(d['id'] ?? '-'),
                      trailing: const Text('-'),
                      onTap: () {
                        if (mounted) {
                          _showToast('${d['name'] ?? d['id']} selected');
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        _showToast('Device query failed: $e');
      }
    } finally {
      // Update cached permission state in case user updated permissions during this flow
      await _updateBtPermission();
    }
  }

  Future<void> _testTorch() async {
    final torch = ref.read(torchServiceProvider);
    try {
      await torch.turnOn();
      _showToast('Torch on');
      await Future.delayed(const Duration(seconds: 1));
      await torch.turnOff();
      _showToast('Torch off');
    } catch (e) {
      _showToast('Torch error: $e');
    }
  }

  Future<void> _testGps() async {
    final pos = await ref.read(gpsServiceProvider).getCurrentPosition();
    if (pos == null) {
      _showToast('Location denied or unavailable');
      return;
    }
    _showToast(
      'Location: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
    );
  }

  Future<void> _testNetwork() async {
    try {
      final res = await ref
          .read(networkServiceProvider)
          .get('https://httpbin.org/get');
      _showToast('Network OK: ${res.statusCode}');
    } catch (e) {
      _showToast('Network error: $e');
    }
  }

  Future<void> _testCapture() async {
    try {
      final camera = ref.read(cameraServiceProvider);
      await camera.initialize();
      final file = await camera.takePhoto();
      await ref
          .read(visionRepositoryProvider)
          .queuePhoto(file, meta: {'source': 'diagnostic'});
      _showToast('Captured & queued: ${file.path}');
    } catch (e) {
      _showToast('Capture error: $e');
    }
  }

  // ----- Bluetooth helpers -----
  Future<void> _updateBtPermission() async {
    try {
      final status = await ref.read(bleServiceProvider).permissionStatus();
      if (mounted) {
        setState(() => _btPermissionStatus = status);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _btPermissionStatus = null);
      }
    }
  }

  Future<void> _requestBluetoothPermission() async {
    try {
      final ok = await ref.read(bleServiceProvider).ensurePermissions();
      await _updateBtPermission();
      _showToast(
        ok ? 'Bluetooth permission granted' : 'Bluetooth permission denied',
      );
    } catch (e) {
      _showToast('Permission request failed: $e');
    }
  }

  String _btPermissionLabel() {
    final s = _btPermissionStatus;
    if (s == null) return 'Unknown';
    if (s.isGranted) return 'Granted';
    if (s.isPermanentlyDenied) return 'Permanently denied';
    if (s.isDenied) return 'Denied';
    if (s.isRestricted) return 'Restricted';
    return s.toString().split('.').last;
  }

  void _openDeleteModal() {
    showDialog(
      context: context,
      builder: (context) {
        return SettingsModalShell(
          title: 'Delete Account',
          primaryText: 'Delete',
          onPrimary: () {
            Navigator.pop(context);
            _showToast('Account deleted');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type DELETE to confirm'),
              const SizedBox(height: 12),
              TextField(
                controller: _deleteController,
                decoration: const InputDecoration(hintText: 'DELETE'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _planLabel(String plan) {
    return plan == 'pro-monthly' ? 'Pro Monthly' : 'Free';
  }
}
