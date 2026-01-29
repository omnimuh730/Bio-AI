import 'package:geolocator/geolocator.dart';

class GpsService {
  Future<bool> ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentPosition() async {
    final ok = await ensurePermission();
    if (!ok) return null;
    const settings = LocationSettings(accuracy: LocationAccuracy.high);
    return await Geolocator.getCurrentPosition(locationSettings: settings);
  }
}
