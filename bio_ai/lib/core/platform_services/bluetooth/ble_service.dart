import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  final FlutterBluePlus _bt = FlutterBluePlus.instance;

  Future<List<ScanResult>> scanOnce({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await _bt.startScan(timeout: timeout);
    // take a short snapshot of results
    final snapshot = await _bt.scanResults.first.timeout(
      const Duration(seconds: 1),
      onTimeout: () => [],
    );
    await _bt.stopScan();
    return snapshot;
  }

  Future<bool> isAvailable() async {
    return await _bt.isAvailable;
  }
}
