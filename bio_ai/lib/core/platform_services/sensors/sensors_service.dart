import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class SensorsService {
  // Raw streams
  Stream<AccelerometerEvent> get accelerometer => accelerometerEventStream();
  Stream<GyroscopeEvent> get gyroscope => gyroscopeEventStream();

  // Smoothed pitch (degrees) computed from accelerometer using atan2
  // Uses a simple moving-average smoothing to avoid jitter.
  Stream<double> get pitchDegrees => _smoothedPitchStream();

  // Whether the device is held within the required pitch window (40-50 deg default)
  Stream<bool> isWithinTargetAngle({double minDeg = 40, double maxDeg = 50}) {
    return pitchDegrees.map((deg) => deg >= minDeg && deg <= maxDeg);
  }

  // Internal: convert raw accel event to degrees and smooth a bit
  Stream<double> _smoothedPitchStream({int window = 5}) {
    final controller = StreamController<double>();
    final buffer = <double>[];
    accelerometer.listen(
      (event) {
        final ax = event.x;
        final ay = event.y;
        final az = event.z;

        // pitch (approx): the tilt forward/backwards
        final rad = atan2(-ax, sqrt(ay * ay + az * az));
        final deg = (rad * (180 / pi)).abs();

        buffer.add(deg);
        if (buffer.length > window) buffer.removeAt(0);
        final avg = buffer.reduce((a, b) => a + b) / buffer.length;
        controller.add(avg);
      },
      onError: controller.addError,
      onDone: controller.close,
    );
    return controller.stream.asBroadcastStream();
  }
}
