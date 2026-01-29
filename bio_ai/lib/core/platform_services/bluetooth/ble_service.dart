import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  /// Scan for devices (legacy). Prefer using [connectedDevices] for already-paired/connected devices.
  Future<List<ScanResult>> scanOnce({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await FlutterBluePlus.startScan(timeout: timeout);
    // take a short snapshot of results
    final snapshot = await FlutterBluePlus.scanResults.first.timeout(
      const Duration(seconds: 1),
      onTimeout: () => [],
    );
    await FlutterBluePlus.stopScan();
    return snapshot;
  }

  /// Return currently connected devices (preferred for quick discovery of paired or connected peripherals)
  Future<List<BluetoothDevice>> connectedDevices() async {
    try {
      // FlutterBluePlus.connectedDevices returns a synchronous List<BluetoothDevice>.
      // Avoid awaiting a non-Future value to satisfy the analyzer.
      return FlutterBluePlus.connectedDevices;
    } catch (e) {
      return <BluetoothDevice>[];
    }
  }

  /// Lightweight summaries for connected devices (name + id) to avoid importing
  /// bluetooth types in UI layers.
  Future<List<Map<String, String>>> connectedDeviceSummaries() async {
    try {
      final devices = await connectedDevices();
      return devices
          .map(
            (d) => {
              'name': d.platformName.isNotEmpty
                  ? d.platformName
                  : d.remoteId.str,
              'id': d.remoteId.str,
            },
          )
          .toList();
    } catch (e) {
      return <Map<String, String>>[];
    }
  }

  /// Ensure runtime permissions needed to query connected BLE devices.
  /// Returns true when permissions are granted or not required on the platform.
  Future<bool> ensurePermissions() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return true;

      // iOS: request Bluetooth permission
      if (Platform.isIOS) {
        final status = await Permission.bluetooth.request();
        return status.isGranted;
      }

      // Android: request Bluetooth scan/connect (Android 12+) and location fallback
      const bluetoothScan = Permission.bluetoothScan;
      const bluetoothConnect = Permission.bluetoothConnect;
      const location = Permission.locationWhenInUse;

      final permissionsToRequest = <Permission>[];

      // Some Android versions may not require bluetooth-specific permissions, include both for safety
      permissionsToRequest.add(bluetoothScan);
      permissionsToRequest.add(bluetoothConnect);
      permissionsToRequest.add(location);

      final statuses = await permissionsToRequest.request();

      // Consider granted if bluetoothConnect OR bluetoothScan is granted and location is granted (or not required)
      final scanOk = statuses[bluetoothScan]?.isGranted == true;
      final connectOk = statuses[bluetoothConnect]?.isGranted == true;
      final locationOk =
          statuses[location]?.isGranted == true ||
          statuses[location] == PermissionStatus.limited;

      return (scanOk || connectOk) && locationOk;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isSupported() async {
    return await FlutterBluePlus.isSupported;
  }
}
