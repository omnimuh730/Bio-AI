import 'package:dio/dio.dart';
import 'package:bio_ai/core/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceState {
  final String label;
  bool connected;
  String lastSync;

  DeviceState(this.label, this.connected, this.lastSync);
}

class SettingsStateHolder extends ChangeNotifier {
  SettingsStateHolder() {
    streamingDevices = List<String>.from(_fallbackDevices);
    _ensureDevices(streamingDevices);
  }

  final Map<String, DeviceState> devices = {};

  // Fallback list when the mock backend isn't reachable.
  final List<String> _fallbackDevices = const [
    'Apple Watch Ultra 2',
    'Oura Ring Gen3',
    'Garmin Fenix 7 Pro',
    'Fitbit Charge 6',
    'Amazfit GTR 4',
  ];

  List<String> streamingDevices = [];
  List<String> _deviceCatalog = [];
  bool _catalogFetched = false;

  // Currently available devices reported by the streaming backend (streaming names)
  Set<String> availableStreaming = {};
  // Devices selected locally to show in Device Sync.
  Set<String> selectedStreaming = {};
  bool _selectionInitialized = false;

  void update(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void updateAvailable(List<String> names) {
    availableStreaming = names.toSet();
    _ensureDevices(availableStreaming);
    for (final name in names) {
      if (!streamingDevices.contains(name)) {
        streamingDevices.add(name);
      }
    }
    if (!_selectionInitialized) {
      selectedStreaming = Set<String>.from(availableStreaming);
      _selectionInitialized = true;
    } else {
      selectedStreaming = selectedStreaming.intersection(availableStreaming);
    }
  }

  void updateStreamingDevices(List<String> names) {
    if (names.isEmpty) return;
    streamingDevices = List<String>.from(names);
    _deviceCatalog = List<String>.from(names);
    _catalogFetched = true;
    _ensureDevices(streamingDevices);
  }

  /// Returns the device names that are currently available (ordered by catalog).
  List<String> get availableDeviceNames {
    if (streamingDevices.isNotEmpty) {
      final ordered = streamingDevices
          .where((name) => availableStreaming.contains(name))
          .toList();
      for (final name in availableStreaming) {
        if (!ordered.contains(name)) {
          ordered.add(name);
        }
      }
      return ordered;
    }
    return availableStreaming.toList();
  }

  /// Returns device names that are selected for Device Sync (ordered by catalog).
  List<String> get selectedDeviceNames {
    if (streamingDevices.isNotEmpty) {
      final ordered = streamingDevices
          .where((name) => selectedStreaming.contains(name))
          .toList();
      for (final name in selectedStreaming) {
        if (!ordered.contains(name)) {
          ordered.add(name);
        }
      }
      return ordered;
    }
    return selectedStreaming.toList();
  }

  void setSelected(String name, bool selected) {
    _ensureDevices([name]);
    if (selected) {
      selectedStreaming.add(name);
    } else {
      selectedStreaming.remove(name);
      final device = devices[name];
      if (device != null) {
        device.connected = false;
        device.lastSync = '';
      }
    }
  }

  bool metricUnits = true;
  String selectedPlan = 'pro-monthly';
  String selectedGoal = 'Lose Fat';
  final TextEditingController deleteController = TextEditingController();
  bool notificationsOn = true;
  bool offlineOn = false;

  PermissionStatus? btPermissionStatus;

  final Dio _dio = Dio();

  void toggleDevice(String name) {
    final device = devices[name];
    if (device == null) return;
    final shouldConnect = !device.connected;
    if (shouldConnect) {
      devices.forEach((_, v) {
        v.connected = false;
        v.lastSync = '';
      });
    }
    device.connected = shouldConnect;
    device.lastSync = shouldConnect ? 'just now' : '';
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

  /// Fetch full device catalog from streaming backend (dev/stage only).
  Future<List<String>> fetchAllDevices({
    bool force = false,
    bool throwOnError = false,
  }) async {
    if (!force && _catalogFetched) return List<String>.from(_deviceCatalog);
    if (!force && !AppConfig.isDevOrStage) {
      return List<String>.from(streamingDevices);
    }
    try {
      final url = '${AppConfig.streamingBaseUrl}/api/devices';
      if (kDebugMode) print('Fetching device catalog from $url');
      final res = await _dio.get(url);
      if (kDebugMode) print('Fetch devices status: ${res.statusCode}');
      if (res.statusCode == 200 && res.data != null) {
        final List l = res.data['devices'] ?? [];
        final names = l.map((e) => e['name']).whereType<String>().toList();
        if (kDebugMode) print('Device catalog: $names');
        return names;
      }
      return List<String>.from(streamingDevices);
    } catch (e) {
      if (kDebugMode) print('fetchAllDevices error: $e');
      if (throwOnError) rethrow;
      return List<String>.from(streamingDevices);
    }
  }

  void _ensureDevices(Iterable<String> names) {
    for (final name in names) {
      devices.putIfAbsent(name, () => DeviceState(name, false, ''));
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
    super.dispose();
  }
}

final settingsStateProvider = ChangeNotifierProvider<SettingsStateHolder>(
  (ref) => SettingsStateHolder(),
);
