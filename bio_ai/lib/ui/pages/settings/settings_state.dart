import 'package:dio/dio.dart';
import 'package:bio_ai/core/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceState {
  final String label;
  bool connected;
  String lastSync;

  DeviceState(this.label, this.connected, this.lastSync);
}

class SettingsStateHolder {
  final Map<String, DeviceState> devices = {
    // Initially no devices are connected in settings; Find Devices will populate
    'apple': DeviceState('Apple Health', false, ''),
    'google': DeviceState('Google Fit', false, ''),
    'garmin': DeviceState('Garmin', false, ''),
    'fitbit': DeviceState('Fitbit', false, ''),
  };

  // Mapping from settings keys to streaming mock device names
  final Map<String, String> _streamingName = {
    'apple': 'Apple Watch Ultra 2',
    'google': 'Oura Ring Gen3',
    'garmin': 'Garmin Fenix 7 Pro',
    'fitbit': 'Fitbit Charge 6',
  };

  String? streamingName(String key) => _streamingName[key];

  String? keyForStreamingName(String name) {
    return _streamingName.entries
            .firstWhere(
              (e) => e.value == name,
              orElse: () => const MapEntry('', ''),
            )
            .key
            .isEmpty
        ? null
        : _streamingName.entries.firstWhere((e) => e.value == name).key;
  }

  Map<String, String> get streamingMap => Map.unmodifiable(_streamingName);

  bool metricUnits = true;
  String selectedPlan = 'pro-monthly';
  String selectedGoal = 'Lose Fat';
  final TextEditingController deleteController = TextEditingController();
  bool notificationsOn = true;
  bool offlineOn = false;

  PermissionStatus? btPermissionStatus;

  final Dio _dio = Dio();

  void toggleDevice(String key) {
    final device = devices[key];
    if (device == null) return;
    device.connected = !device.connected;
    device.lastSync = device.connected ? 'just now' : '';
  }

  /// Fetch available devices from streaming backend (dev/stage only)
  /// Fetch available devices from streaming backend.
  ///
  /// If [force] is false (default), this will only run in dev/stage modes.
  Future<List<String>> fetchAvailableDevices({
    bool force = false,
    bool throwOnError = false,
  }) async {
    if (!force && !AppConfig.isDevOrStage) return [];
    try {
      final url = '${AppConfig.streamingBaseUrl}/api/available';
      if (kDebugMode) print('Fetching available devices from $url');
      final res = await _dio.get(url);
      if (kDebugMode) print('Fetch available status: ${res.statusCode}');
      if (res.statusCode == 200 && res.data != null) {
        final List l = res.data['available'] ?? [];
        if (kDebugMode) print('Available devices: $l');
        return List<String>.from(l);
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('fetchAvailableDevices error: $e');
      if (throwOnError) rethrow;
      return [];
    }
  }

  /// Expose or hide a device on the streaming backend (dev/stage only).
  /// Returns true on success.
  Future<bool> setDeviceExposure(
    String key,
    bool expose, {
    bool force = false,
  }) async {
    if (!force && !AppConfig.isDevOrStage) return false;
    final name = _streamingName[key];
    if (name == null) return false;
    final endpoint = expose ? 'expose' : 'hide';
    try {
      final url = '${AppConfig.streamingBaseUrl}/api/$endpoint';
      if (kDebugMode) print('POST $url -> $name');
      final res = await _dio.post(url, data: {'device': name});
      final ok =
          res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300;
      if (!ok && kDebugMode)
        print('setDeviceExposure non-ok status: ${res.statusCode}');
      return ok;
    } catch (e) {
      if (kDebugMode) print('setDeviceExposure error: $e');
      return false;
    }
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
