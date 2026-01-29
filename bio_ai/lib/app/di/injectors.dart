import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/core/platform_services/sensors/sensors_service.dart';
import 'package:bio_ai/core/platform_services/location/gps_service.dart';
import 'package:bio_ai/core/platform_services/bluetooth/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bio_ai/core/platform_services/flashlight/torch_service.dart';
import 'package:bio_ai/core/platform_services/network/network_service.dart';
import 'package:bio_ai/core/platform_services/camera/camera_service.dart';
import 'package:bio_ai/core/platform_services/offline/offline_queue_service.dart';
import 'package:bio_ai/features/vision/data/repositories/vision_repository_impl.dart';

final sensorsServiceProvider = Provider((ref) => SensorsService());
final gpsServiceProvider = Provider((ref) => GpsService());
final bleServiceProvider = Provider((ref) => BleService());

// Provider to expose connected devices for UI without importing BLE package types.
final connectedDevicesProvider =
    FutureProvider.autoDispose<List<BluetoothDevice>>(
      (ref) => ref.read(bleServiceProvider).connectedDevices(),
    );

// Provider that ensures necessary permissions and returns lightweight summaries for UI consumption.
final connectedDeviceSummariesProvider =
    FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
      final ble = ref.read(bleServiceProvider);
      final ok = await ble.ensurePermissions();
      if (!ok) throw Exception('Bluetooth permissions denied');
      return await ble.connectedDeviceSummaries();
    });

final torchServiceProvider = Provider((ref) => TorchService());
final networkServiceProvider = Provider((ref) => NetworkService());
final offlineQueueProvider = Provider(
  (ref) => OfflineQueueService(network: ref.read(networkServiceProvider)),
);
final visionRepositoryProvider = Provider<VisionRepositoryImpl>(
  (ref) => VisionRepositoryImpl(
    network: ref.read(networkServiceProvider),
    queue: ref.read(offlineQueueProvider),
  ),
);
final cameraServiceProvider = Provider((ref) => CameraService());

// Future provider to initialize the camera once (used by UI)
final cameraInitProvider = FutureProvider<void>(
  (ref) => ref.read(cameraServiceProvider).initialize(),
);

// Example stream provider for device pitch (from accelerometer)
final pitchProvider = StreamProvider<double>(
  (ref) => ref.read(sensorsServiceProvider).pitchDegrees,
);
