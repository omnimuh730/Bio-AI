import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
      return await FlutterBluePlus.connectedDevices;
    } catch (e) {
      return <BluetoothDevice>[];
    }
  }

  Future<bool> isSupported() async {
    return await FlutterBluePlus.isSupported;
  }
}
