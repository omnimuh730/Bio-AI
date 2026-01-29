import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
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

  Future<bool> isSupported() async {
    return await FlutterBluePlus.isSupported;
  }
}
