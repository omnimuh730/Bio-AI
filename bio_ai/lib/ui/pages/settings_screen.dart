import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/core/config.dart';
import 'package:bio_ai/services/streaming_service.dart';

import 'package:bio_ai/ui/pages/settings/widgets/settings_profile.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_device.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_preference.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_diatery.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_diagnostics.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_goal.dart';
import 'package:bio_ai/ui/pages/settings/widgets/settings_account.dart';

import 'package:bio_ai/ui/pages/settings/settings_helper.dart';

import 'package:bio_ai/ui/pages/settings/core/core_components.dart';

import 'package:bio_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bio_ai/features/vision/presentation/screens/capture_screen.dart';
import 'package:bio_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bio_ai/features/planner/presentation/screens/planner_screen.dart';
import 'settings/settings_state.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _s = SettingsStateHolder();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Check Bluetooth permission status once the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateBtPermission());

    // Start polling streaming backend for available devices when in dev/stage
    if (AppConfig.isDevOrStage) {
      // run immediately and then every 5s
      _refreshAvailableDevices();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _refreshAvailableDevices(),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _s.dispose();
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

  void _toggleDevice(String name) {
    // Client-side: connect only one device locally. Do not clear other available devices on backend.
    final wasConnected = _s.devices[name]?.connected == true;
    final label = _s.devices[name]?.label ?? name;

    if (AppConfig.isDevOrStage) {
      if (wasConnected) {
        // disconnect locally
        setState(() {
          _s.devices[name]?.connected = false;
          _s.devices[name]?.lastSync = '';
        });
        StreamingService.instance.setSelectedDevice(null);
        StreamingService.instance.stop();
        _showToast('$label disconnected');
      } else {
        // connect this device locally and ensure backend marks it available
        setState(() {
          // only one connected locally
          _s.devices.forEach((k, v) {
            v.connected = false;
            v.lastSync = '';
          });
          _s.devices[name]?.connected = true;
          _s.devices[name]?.lastSync = 'just now';
        });
        // set selected device so dashboard shows its metrics
        StreamingService.instance.setSelectedDevice(name);
        StreamingService.instance.start(force: true);
        _showToast('$label connected');
      }
      return;
    }

    // Prod: local bluetooth flow
    setState(() => _s.toggleDevice(name));
    _showToast(
      '$label ${_s.devices[name]?.connected == true ? 'connected' : 'disconnected'}',
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
                  devices: _s.devices,
                  availableDevices: _s.availableDeviceNames,
                  onToggle: _toggleDevice,
                  onResync: () => _showToast('Resyncing devices...'),
                  onReauth: () => _showToast('Re-auth requested'),
                  onFind: _openFindDevicesModal,
                ),
                SettingsDietarySection(
                  onChipTap: (chip) => _showToast('$chip selected'),
                ),
                SettingsPreferenceSection(
                  metricUnits: _s.metricUnits,
                  onMetricChanged: (value) =>
                      setState(() => _s.metricUnits = value),
                  notificationsOn: _s.notificationsOn,
                  onNotificationsChanged: (value) =>
                      setState(() => _s.notificationsOn = value),
                  offlineOn: _s.offlineOn,
                  onOfflineChanged: (value) =>
                      setState(() => _s.offlineOn = value),
                ),
                SettingsGoalSection(
                  goals: [
                    SettingsGoalItem(
                      title: 'Lose Fat',
                      selected: _s.selectedGoal == 'Lose Fat',
                    ),
                    SettingsGoalItem(
                      title: 'Build Muscle',
                      selected: _s.selectedGoal == 'Build Muscle',
                    ),
                    SettingsGoalItem(
                      title: 'Maintain & Cognitive',
                      selected: _s.selectedGoal == 'Maintain & Cognitive',
                    ),
                  ],
                  onGoalTap: (title) {
                    setState(() => _s.selectedGoal = title);
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
                SettingsDiagnosticsSection(
                  onTestTorch: _testTorch,
                  onTestGps: _testGps,
                  onTestNetwork: _testNetwork,
                  onShowDevices: _openFindDevicesModal,
                  onRequestPermission: _requestBluetoothPermission,
                  onTestCapture: _testCapture,
                  btPermissionLabel: _s.btPermissionLabel(),
                  onRefresh: () async {
                    await _updateBtPermission();
                    ref.invalidate(connectedDeviceSummariesProvider);
                    _showToast('Refreshing devices...');
                  },
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

  void _openSubscriptionModal() =>
      openSubscriptionModal(context, ref, _s, _showToast, (fn) => setState(fn));

  void _openExportModal() => openExportModal(context, _showToast);

  Future<void> _openFindDevicesModal() =>
      openFindDevicesModal(context, ref, _s, _showToast, (fn) => setState(fn));
  Future<void> _testTorch() async => testTorch(ref, _showToast);
  Future<void> _testGps() async => testGps(ref, _showToast);
  Future<void> _testNetwork() async => testNetwork(ref, _showToast);
  Future<void> _testCapture() async => testCapture(ref, _showToast);
  // ----- Bluetooth helpers -----
  Future<void> _updateBtPermission() async =>
      updateBtPermission(ref, _s, (fn) => setState(fn));

  Future<void> _requestBluetoothPermission() async =>
      requestBluetoothPermission(ref, _s, (fn) => setState(fn), _showToast);
  void _openDeleteModal() => openDeleteModal(context, _s, _showToast);

  Future<void> _refreshAvailableDevices() async {
    try {
      final allDevices = await _s.fetchAllDevices();
      final available = await _s.fetchAvailableDevices();
      // update state holder with available list and refresh UI
      setState(() {
        if (allDevices.isNotEmpty) {
          _s.updateStreamingDevices(allDevices);
        }
        _s.updateAvailable(available);
        // do NOT mark devices as connected just because they're available;
        // connected means locally selected (only one). Keep lastSync for visible devices.
        _s.devices.forEach((name, v) {
          if (available.contains(name)) {
            v.lastSync = v.lastSync.isEmpty ? 'available' : v.lastSync;
          } else {
            if (!v.connected) v.lastSync = '';
          }
        });
      });
    } catch (e) {
      // ignore errors
    }
  }
}
