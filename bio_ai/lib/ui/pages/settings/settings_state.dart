import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/device_state.dart';

class SettingsStateHolder {
  final Map<String, DeviceState> devices = {
    'apple': DeviceState('Apple Health', true, '2m ago'),
    'google': DeviceState('Google Fit', false, ''),
    'garmin': DeviceState('Garmin', false, ''),
    'fitbit': DeviceState('Fitbit', true, '12m ago'),
  };

  bool metricUnits = true;
  String selectedPlan = 'pro-monthly';
  String selectedGoal = 'Lose Fat';
  final TextEditingController deleteController = TextEditingController();
  bool notificationsOn = true;
  bool offlineOn = false;

  PermissionStatus? btPermissionStatus;

  void toggleDevice(String key) {
    final device = devices[key];
    if (device == null) return;
    device.connected = !device.connected;
    device.lastSync = device.connected ? 'just now' : '';
  }

  String planLabel(String plan) {
    switch (plan) {
      case 'pro-annual':
        return 'Pro Annual';
      case 'free':
        return 'Free';
      default:
        return 'Pro Monthly';
    }
  }

  String btPermissionLabel() {
    final s = btPermissionStatus;
    if (s == null) return 'Unknown';
    if (s.isGranted) return 'Granted';
    if (s.isPermanentlyDenied) return 'Permanently denied';
    if (s.isDenied) return 'Denied';
    if (s.isRestricted) return 'Restricted';
    return s.toString().split('.').last;
  }

  void dispose() {
    deleteController.dispose();
  }
}
