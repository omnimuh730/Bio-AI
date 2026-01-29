import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/core/platform_services/sensors/sensors_service.dart';
import 'package:bio_ai/core/platform_services/location/gps_service.dart';
import 'package:bio_ai/core/platform_services/bluetooth/ble_service.dart';
import 'package:bio_ai/core/platform_services/flashlight/torch_service.dart';
import 'package:bio_ai/core/platform_services/network/network_service.dart';
import 'package:bio_ai/core/platform_services/camera/camera_service.dart';
import 'package:bio_ai/core/platform_services/offline/offline_queue_service.dart';
import 'package:bio_ai/features/vision/data/repositories/vision_repository_impl.dart';

final sensorsServiceProvider = Provider((ref) => SensorsService());
final gpsServiceProvider = Provider((ref) => GpsService());
final bleServiceProvider = Provider((ref) => BleService());
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

// Example stream provider for device pitch (from accelerometer)
final pitchProvider = StreamProvider<double>(
  (ref) => ref.read(sensorsServiceProvider).pitchDegrees,
);
