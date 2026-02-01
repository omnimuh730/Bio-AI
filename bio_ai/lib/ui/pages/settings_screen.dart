import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/app/di/injectors.dart';

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

  @override
  void initState() {
    super.initState();
    // Check Bluetooth permission status once the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateBtPermission());
  }

  @override
  void dispose() {
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

  void _toggleDevice(String key) {
    setState(() => _s.toggleDevice(key));
    _showToast(
      '${_s.devices[key]?.label} ${_s.devices[key]?.connected == true ? 'connected' : 'disconnected'}',
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
}
