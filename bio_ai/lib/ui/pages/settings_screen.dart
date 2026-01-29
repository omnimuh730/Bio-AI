import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import '../organisms/floating_nav_bar.dart';
import 'analytics_screen.dart';
import 'capture_screen.dart';
import 'dashboard_screen.dart';
import 'planner_screen.dart';
import 'settings/models/device_state.dart';
import 'settings/widgets/settings_account_section.dart';
import 'settings/widgets/settings_device_section.dart';
import 'settings/widgets/settings_dietary_section.dart';
import 'settings/widgets/settings_goal_section.dart';
import 'settings/widgets/settings_modal_shell.dart';
import 'settings/widgets/settings_plan_options.dart';
import 'settings/widgets/settings_preference_section.dart';
import 'settings/widgets/settings_profile_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                  Text(
                    'Current plan: ${_planLabel(_selectedPlan)}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SettingsPlanOptions(
                    selectedPlan: _selectedPlan,
                    onPlanSelected: (plan) {
                      setState(() => _selectedPlan = plan);
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

  String _planLabel(String plan) {
    switch (plan) {
      case 'pro-annual':
        return 'Pro Annual';
      case 'free':
        return 'Free';
      default:
        return 'Pro Monthly';
    }
  }

  void _openExportModal() {
    showDialog(
      context: context,
      builder: (context) {
        return SettingsModalShell(
          title: 'Export Data',
          primaryText: 'Download CSV',
          onPrimary: () {
            Navigator.pop(context);
            _showToast('Export started');
          },
          child: Text(
            'CSV export ready. This is a mock download.',
            style: AppTextStyles.bodySmall,
          ),
        );
      },
    );
  }

  void _openFindDevicesModal() {
    showDialog(
      context: context,
      builder: (context) {
        return SettingsModalShell(
          title: 'Find Devices',
          primaryText: 'Done',
          onPrimary: () {
            Navigator.pop(context);
            _showToast('Scan complete');
          },
          child: Text(
            'Scanning nearby devices... (mock)',
            style: AppTextStyles.bodySmall,
          ),
        );
      },
    );
  }

  void _openDeleteModal() {
    _deleteController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return SettingsModalShell(
          title: 'Delete Account',
          primaryText: 'Confirm Delete',
          primaryColor: const Color(0xFFEF4444),
          primaryEnabled:
              _deleteController.text.trim().toUpperCase() == 'DELETE',
          onPrimary: () {
            Navigator.pop(context);
            _showToast('Account deleted (mock)');
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
                controller: _deleteController,
                onChanged: (_) => setState(() {}),
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
  }
}
