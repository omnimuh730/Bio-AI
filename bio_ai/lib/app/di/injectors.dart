import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/core/platform_services/sensors/sensors_service.dart';
import 'package:bio_ai/core/platform_services/location/gps_service.dart';
import 'package:bio_ai/core/platform_services/bluetooth/ble_service.dart';
import 'package:bio_ai/core/platform_services/flashlight/torch_service.dart';
import 'package:bio_ai/core/platform_services/network/network_service.dart';

final sensorsServiceProvider = Provider((ref) => SensorsService());
final gpsServiceProvider = Provider((ref) => GpsService());
final bleServiceProvider = Provider((ref) => BleService());
final torchServiceProvider = Provider((ref) => TorchService());
final networkServiceProvider = Provider((ref) => NetworkService());

// Example stream provider for device pitch (from accelerometer)
final pitchProvider = StreamProvider<double>(
  (ref) => ref.read(sensorsServiceProvider).pitchAngle,
);
