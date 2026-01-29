import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class SensorsService {
  Stream<AccelerometerEvent> get accelerometer => accelerometerEvents;
  Stream<GyroscopeEvent> get gyroscope => gyroscopeEvents;

  // Example: compute a simple pitch angle from accelerometer
  Stream<double> get pitchAngle => accelerometer.map((event) {
    final ax = event.x;
    final ay = event.y;
    final az = event.z;
    // Very simple conversion to pitch (radians)
    final pitch = (ax / (az == 0 ? 0.0001 : az));
    return pitch;
  });
}
