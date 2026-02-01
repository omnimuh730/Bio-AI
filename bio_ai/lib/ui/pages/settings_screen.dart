import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/ui/organisms/floating_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/app/di/injectors.dart';
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

// ---------- Helpers (inlined) ----------
Future<void> openSubscriptionModal(
  BuildContext context,
  WidgetRef ref,
  SettingsStateHolder s,
  void Function(String) showToast,
  void Function(VoidCallback) setParentState,
) async {
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
              showToast('Plan updated to ${s.planLabel(s.selectedPlan)}');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current plan: ${s.planLabel(s.selectedPlan)}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                SettingsPlanOptions(
                  selectedPlan: s.selectedPlan,
                  onPlanSelected: (plan) {
                    setParentState(() => s.selectedPlan = plan);
                    setModalState(() {});
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> openExportModal(
  BuildContext context,
  void Function(String) showToast,
) async {
  showDialog(
    context: context,
    builder: (context) {
      return SettingsModalShell(
        title: 'Export Data',
        primaryText: 'Download CSV',
        onPrimary: () {
          Navigator.pop(context);
          showToast('Export started');
        },
        child: Text(
          'CSV export ready. This is a mock download.',
          style: AppTextStyles.bodySmall,
        ),
      );
    },
  );
}

Future<void> openFindDevicesModal(
  BuildContext context,
  WidgetRef ref,
  SettingsStateHolder s,
  void Function(String) showToast,
  void Function(VoidCallback) setParentState,
) async {
  final ble = ref.read(bleServiceProvider);
  final ok = await ble.ensurePermissions();
  await updateBtPermission(ref, s, setParentState);

  if (!ok) {
    if (!context.mounted) return;
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
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    return;
  }

  showToast('Fetching connected Bluetooth devices...');
  final supported = await ble.isSupported();
  if (!supported) {
    showToast('Bluetooth not supported on this device');
    return;
  }

  final devices = await ble.connectedDeviceSummaries();
  if (devices.isEmpty) {
    showToast('No connected devices found');
    return;
  }

  if (!context.mounted) return;
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
                  onTap: () => showToast('${d['name'] ?? d['id']} selected'),
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
}

Future<void> updateBtPermission(
  WidgetRef ref,
  SettingsStateHolder s,
  void Function(VoidCallback) setParentState,
) async {
  try {
    final status = await ref.read(bleServiceProvider).permissionStatus();
    setParentState(() => s.btPermissionStatus = status);
  } catch (_) {
    setParentState(() => s.btPermissionStatus = null);
  }
}

Future<void> requestBluetoothPermission(
  WidgetRef ref,
  SettingsStateHolder s,
  void Function(VoidCallback) setParentState,
  void Function(String) showToast,
) async {
  try {
    final ok = await ref.read(bleServiceProvider).ensurePermissions();
    await updateBtPermission(ref, s, setParentState);
    showToast(
      ok ? 'Bluetooth permission granted' : 'Bluetooth permission denied',
    );
  } catch (e) {
    showToast('Permission request failed: $e');
  }
}

Future<void> testTorch(WidgetRef ref, void Function(String) showToast) async {
  final torch = ref.read(torchServiceProvider);
  try {
    await torch.turnOn();
    showToast('Torch on');
    await Future.delayed(const Duration(seconds: 1));
    await torch.turnOff();
    showToast('Torch off');
  } catch (e) {
    showToast('Torch error: $e');
  }
}

Future<void> testGps(WidgetRef ref, void Function(String) showToast) async {
  final pos = await ref.read(gpsServiceProvider).getCurrentPosition();
  if (pos == null) {
    showToast('Location denied or unavailable');
    return;
  }
  showToast(
    'Location: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
  );
}

Future<void> testNetwork(WidgetRef ref, void Function(String) showToast) async {
  try {
    final res = await ref
        .read(networkServiceProvider)
        .get('https://httpbin.org/get');
    showToast('Network OK: ${res.statusCode}');
  } catch (e) {
    showToast('Network error: $e');
  }
}

Future<void> testCapture(WidgetRef ref, void Function(String) showToast) async {
  try {
    final camera = ref.read(cameraServiceProvider);
    await camera.initialize();
    final file = await camera.takePhoto();
    await ref
        .read(visionRepositoryProvider)
        .queuePhoto(file, meta: {'source': 'diagnostic'});
    showToast('Captured & queued: ${file.path}');
  } catch (e) {
    showToast('Capture error: $e');
  }
}

Future<void> openDeleteModal(
  BuildContext context,
  SettingsStateHolder s,
  void Function(String) showToast,
) async {
  s.deleteController.clear();
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SettingsModalShell(
            title: 'Delete Account',
            primaryText: 'Confirm Delete',
            primaryColor: const Color(0xFFEF4444),
            primaryEnabled:
                s.deleteController.text.trim().toUpperCase() == 'DELETE',
            onPrimary: () {
              Navigator.pop(context);
              showToast('Account deleted (mock)');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will permanently remove your health data (mock).',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                Text('Type DELETE to confirm.', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                TextField(
                  controller: s.deleteController,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Type DELETE',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ---------- UI (inlined) ----------
class SettingsProfileHeader extends StatelessWidget {
  const SettingsProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  'PRO',
                  style: AppTextStyles.proLabel.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dekomori Sanae',
            style: AppTextStyles.header1.copyWith(color: AppColors.textMain),
          ),
          const SizedBox(height: 4),
          Text(
            'sanae@Bio AI.ai',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class SettingsDeviceSection extends StatelessWidget {
  final Map<String, DeviceState> devices;
  final ValueChanged<String> onToggle;
  final VoidCallback onResync;
  final VoidCallback onReauth;
  final VoidCallback onFind;

  const SettingsDeviceSection({
    super.key,
    required this.devices,
    required this.onToggle,
    required this.onResync,
    required this.onReauth,
    required this.onFind,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Device Sync'),
        SettingsCardContainer(
          children: [
            SettingsDeviceRow(
              device: devices['apple']!,
              icon: Icons.apple,
              iconColor: AppColors.textMain,
              onToggle: () => onToggle('apple'),
            ),
            const SettingsDivider(),
            SettingsDeviceRow(
              device: devices['google']!,
              icon: Icons.g_mobiledata,
              iconColor: AppColors.textMain,
              onToggle: () => onToggle('google'),
            ),
            const SettingsDivider(),
            SettingsDeviceRow(
              device: devices['garmin']!,
              icon: Icons.watch,
              iconColor: AppColors.textMain,
              onToggle: () => onToggle('garmin'),
            ),
            const SettingsDivider(),
            SettingsDeviceRow(
              device: devices['fitbit']!,
              icon: Icons.favorite_border,
              iconColor: AppColors.textMain,
              onToggle: () => onToggle('fitbit'),
            ),
            SettingsActionRow(
              label: 'Resync Devices',
              icon: Icons.sync,
              color: AppColors.accentGreen,
              background: const Color(0xFFF0FDF4),
              onTap: onResync,
            ),
            SettingsActionRow(
              label: 'Re-Auth Devices',
              icon: Icons.verified_user_outlined,
              color: AppColors.accentBlue,
              background: const Color(0xFFEEF2FF),
              onTap: onReauth,
            ),
            SettingsActionRow(
              label: 'Find Devices',
              icon: Icons.wifi_tethering,
              color: AppColors.textMain,
              background: const Color(0xFFF8FAFC),
              onTap: onFind,
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsDietarySection extends StatelessWidget {
  final ValueChanged<String> onChipTap;

  const SettingsDietarySection({super.key, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    final chips = ['Vegan', 'Keto', 'Paleo', 'Pescatarian', 'Mediterranean'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Dietary Profile'),
        SettingsCardContainer(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: chips
                    .map(
                      (chip) => SettingsSelectableChip(
                        label: chip,
                        onTap: () => onChipTap(chip),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  SettingsInputField(
                    label: 'Allergies',
                    hint: 'Peanuts, Gluten, Dairy',
                  ),
                  SizedBox(height: 12),
                  SettingsInputField(label: 'Dislikes', hint: 'Mushrooms'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsPreferenceSection extends StatelessWidget {
  final bool metricUnits;
  final ValueChanged<bool> onMetricChanged;
  final bool notificationsOn;
  final ValueChanged<bool> onNotificationsChanged;
  final bool offlineOn;
  final ValueChanged<bool> onOfflineChanged;

  const SettingsPreferenceSection({
    super.key,
    required this.metricUnits,
    required this.onMetricChanged,
    required this.notificationsOn,
    required this.onNotificationsChanged,
    required this.offlineOn,
    required this.onOfflineChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Preferences'),
        SettingsCardContainer(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SettingsUnitToggle(
                    metricUnits: metricUnits,
                    onChanged: onMetricChanged,
                  ),
                  const SizedBox(height: 16),
                  SettingsUnitPreview(metricUnits: metricUnits),
                ],
              ),
            ),
            SettingsSwitchRow(
              title: 'Notifications',
              subtitle: 'Smart reminders and bio alerts.',
              value: notificationsOn,
              onChanged: onNotificationsChanged,
            ),
            const SettingsDivider(),
            SettingsSwitchRow(
              title: 'Offline Mode',
              subtitle: 'Queue uploads and cache today plan.',
              value: offlineOn,
              onChanged: onOfflineChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsGoalItem {
  final String title;
  final bool selected;

  const SettingsGoalItem({required this.title, required this.selected});
}

class SettingsGoalSection extends StatelessWidget {
  final List<SettingsGoalItem> goals;
  final ValueChanged<String> onGoalTap;

  const SettingsGoalSection({
    super.key,
    required this.goals,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Goal Setting'),
        SettingsCardContainer(
          children: goals
              .map(
                (goal) => SettingsGoalOption(
                  title: goal.title,
                  selected: goal.selected,
                  onTap: () => onGoalTap(goal.title),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class SettingsAccountSection extends StatelessWidget {
  final VoidCallback onOnboarding;
  final VoidCallback onManageSubscription;
  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;

  const SettingsAccountSection({
    super.key,
    required this.onOnboarding,
    required this.onManageSubscription,
    required this.onExportData,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SettingsSectionLabel('Account'),
        SettingsCardContainer(
          children: [
            SettingsAccountRow(
              label: 'Revisit Onboarding',
              icon: Icons.list_alt_outlined,
              onTap: onOnboarding,
            ),
            const SettingsDivider(),
            SettingsAccountRow(
              label: 'Manage Subscription',
              icon: Icons.workspace_premium_outlined,
              onTap: onManageSubscription,
              color: const Color(0xFFF59E0B),
            ),
            const SettingsDivider(),
            SettingsAccountRow(
              label: 'Export Data',
              icon: Icons.file_download_outlined,
              onTap: onExportData,
            ),
            const SettingsDivider(),
            SettingsAccountRow(
              label: 'Delete Account',
              icon: Icons.delete_outline,
              onTap: onDeleteAccount,
              color: const Color(0xFFEF4444),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class SettingsDiagnosticsSection extends ConsumerWidget {
  final VoidCallback onTestTorch;
  final VoidCallback onTestGps;
  final VoidCallback onTestNetwork;
  final VoidCallback onShowDevices;
  final VoidCallback onRequestPermission;
  final VoidCallback onTestCapture;
  final String btPermissionLabel;
  final VoidCallback onRefresh;

  const SettingsDiagnosticsSection({
    super.key,
    required this.onTestTorch,
    required this.onTestGps,
    required this.onTestNetwork,
    required this.onShowDevices,
    required this.onRequestPermission,
    required this.onTestCapture,
    required this.btPermissionLabel,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
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
                onPressed: onTestTorch,
                child: const Text('Torch'),
              ),
              ElevatedButton(onPressed: onTestGps, child: const Text('GPS')),
              ElevatedButton(
                onPressed: onTestNetwork,
                child: const Text('Network'),
              ),
              Chip(label: Text('Bluetooth: $btPermissionLabel')),
              ElevatedButton(
                onPressed: onShowDevices,
                child: const Text('Show Devices'),
              ),
              TextButton(
                onPressed: onRequestPermission,
                child: const Text('Request Permission'),
              ),
              ElevatedButton(
                onPressed: onTestCapture,
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
                      onPressed: onRefresh,
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
                                  title: Text(d['name'] ?? 'Unknown'),
                                  subtitle: Text(d['id'] ?? '-'),
                                  onTap: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${d['name'] ?? d['id']} selected',
                                          ),
                                        ),
                                      ),
                                ),
                              )
                              .toList(),
                        );
                      },
                      loading: () => const SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Unable to load devices: ${e.toString()}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onRequestPermission,
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
    );
  }
}

class SettingsAccountRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const SettingsAccountRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Icon(
                icon,
                size: 18,
                color: color ?? AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color ?? AppColors.textMain,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class SettingsActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const SettingsActionRow({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class SettingsCardContainer extends StatelessWidget {
  final List<Widget> children;

  const SettingsCardContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }
}

class SettingsDeviceRow extends StatelessWidget {
  final DeviceState device;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onToggle;

  const SettingsDeviceRow({
    super.key,
    required this.device,
    required this.icon,
    required this.iconColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.label,
                  style: AppTextStyles.dmSans14SemiBold.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.connected
                      ? 'Synced: ${device.lastSync.isEmpty ? 'just now' : device.lastSync}'
                      : 'Disconnected',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: device.connected
                        ? AppColors.accentGreen
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SettingsToggleSwitch(
            value: device.connected,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }
}

class SettingsGoalOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SettingsGoalOption({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.accentBlue : const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0x0D4B7BFF) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.dmSans14SemiBold),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.accentBlue
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: AppColors.accentBlue,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsInputField extends StatelessWidget {
  final String label;
  final String hint;

  const SettingsInputField({
    super.key,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.labelSmall,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsModalShell extends StatelessWidget {
  final String title;
  final Widget child;
  final String primaryText;
  final VoidCallback onPrimary;
  final Color primaryColor;
  final bool primaryEnabled;

  const SettingsModalShell({
    super.key,
    required this.title,
    required this.child,
    required this.primaryText,
    required this.onPrimary,
    this.primaryColor = const Color(0xFF2563EB),
    this.primaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textMain,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
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
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: primaryEnabled ? onPrimary : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      primaryText,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: AppColors.textMain,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPlanOptions extends StatelessWidget {
  final String selectedPlan;
  final ValueChanged<String> onPlanSelected;

  const SettingsPlanOptions({
    super.key,
    required this.selectedPlan,
    required this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = {
      'pro-monthly': 'Pro Monthly',
      'pro-annual': 'Pro Annual',
      'free': 'Free',
    };
    return Column(
      children: options.entries.map((entry) {
        final selected = selectedPlan == entry.key;
        return GestureDetector(
          onTap: () => onPlanSelected(entry.key),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.accentBlue
                    : const Color(0xFFE2E8F0),
              ),
              color: selected ? const Color(0x144B7BFF) : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.value,
                  style: AppTextStyles.dmSans14SemiBold.copyWith(
                    color: selected ? AppColors.accentBlue : AppColors.textMain,
                  ),
                ),
                Text(
                  entry.key == 'pro-monthly'
                      ? '\$9.99'
                      : entry.key == 'pro-annual'
                      ? '\$79'
                      : '5 scans/week',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.accentBlue
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  final String label;

  const SettingsSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class SettingsSelectableChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const SettingsSelectableChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<SettingsSelectableChip> createState() => _SettingsSelectableChipState();
}

class _SettingsSelectableChipState extends State<SettingsSelectableChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _selected = !_selected);
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selected ? const Color(0x1A4B7BFF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selected ? AppColors.accentBlue : Colors.transparent,
          ),
        ),
        child: Text(
          widget.label,
          style: AppTextStyles.labelSmall.copyWith(
            color: _selected ? AppColors.accentBlue : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.dmSans16Bold),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          SettingsToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class SettingsToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsToggleSwitch({super.key, this.value = false, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.accentGreen : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsUnitCard extends StatelessWidget {
  final String label;
  final String value;

  const SettingsUnitCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class SettingsUnitPreview extends StatelessWidget {
  final bool metricUnits;

  const SettingsUnitPreview({super.key, required this.metricUnits});

  @override
  Widget build(BuildContext context) {
    final weight = metricUnits ? '72 kg' : '159 lb';
    final height = metricUnits ? '172 cm' : '5 ft 8 in';
    final water = metricUnits ? '2,500 ml' : '84 oz';
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      children: [
        SettingsUnitCard(label: 'Weight', value: weight),
        SettingsUnitCard(label: 'Height', value: height),
        SettingsUnitCard(label: 'Water Goal', value: water),
        const SettingsUnitCard(label: 'Active Burn', value: '620 kcal'),
      ],
    );
  }
}

class SettingsUnitToggle extends StatelessWidget {
  final bool metricUnits;
  final ValueChanged<bool> onChanged;

  const SettingsUnitToggle({
    super.key,
    required this.metricUnits,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _toggleButton('Metric', metricUnits),
          _toggleButton('Imperial', !metricUnits),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(label == 'Metric'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTextStyles.button),
        ),
      ),
    );
  }
}
