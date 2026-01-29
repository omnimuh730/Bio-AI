import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class SensorsService {
  Stream<AccelerometerEvent> get accelerometer => accelerometerEventStream();
  Stream<GyroscopeEvent> get gyroscope => gyroscopeEventStream();

  // Example: compute a simple pitch angle from accelerometer
  Stream<double> get pitchAngle => accelerometer.map((event) {
        final ax = event.x;
        final az = event.z;
        // Very simple conversion to pitch (ratio)
