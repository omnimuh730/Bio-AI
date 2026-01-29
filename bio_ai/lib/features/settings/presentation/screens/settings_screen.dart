import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
                          ElevatedButton(
                            onPressed: _openFindDevicesModal,
                            child: const Text('Scan BLE'),
                          ),
                          ElevatedButton(
                            onPressed: _testCapture,
                            child: const Text('Capture'),
                          ),
                        ],
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
    _showToast('Scanning for nearby devices...');
    try {
      final results = await ref.read(bleServiceProvider).scanOnce();
      if (results.isEmpty) {
        _showToast('No devices found');
        return;
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nearby devices'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: results
                  .map(
                    (r) => ListTile(
                      title: Text(
                        r.device.name.isNotEmpty
                            ? r.device.name
                            : r.device.id.id,
                      ),
                      subtitle: Text(r.advertisementData.localName ?? ''),
                      trailing: Text(r.rssi.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showToast('Scan failed: $e');
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
