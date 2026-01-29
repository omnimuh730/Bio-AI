## Platform Permissions & Setup (Android & iOS) ⚠️

Add the following to enable camera, sensors, location, bluetooth and torch functionality.

Android (android/app/src/main/AndroidManifest.xml)

- Add permissions inside `<manifest>`:
    - `<uses-permission android:name="android.permission.CAMERA" />`
    - `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
    - `<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />` (Android 12+)
    - `<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />` (Android 12+)
    - `<uses-permission android:name="android.permission.BLUETOOTH" />`
    - `<uses-permission android:name="android.permission.RECORD_AUDIO" />` (if using mic)
    - `<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />` (optional for background tasks)

- Add `queries` for bluetooth devices if targeting Android 12+: `<queries><intent>...</intent></queries>` (see docs)

iOS (ios/Runner/Info.plist)

- Add usage descriptions:
    - `NSCameraUsageDescription` - "Used to capture food images for volume estimation"
    - `NSLocationWhenInUseUsageDescription` - "Used to detect restaurant location for Menu Coach"
    - `NSBluetoothAlwaysUsageDescription` - "Used to pair with wearable devices"
    - `NSMicrophoneUsageDescription` - "Optional: for barcode scanning using audio or voice features"

Notes & tips:

- Use `permission_handler` to request and check permissions at runtime.
- For `camera` plugin: configure `AndroidX` and follow package docs to add `camera` permission.
- On iOS simulator the camera is not available—test on real devices for sensor / camera features.

Recommended packages added to `pubspec.yaml`:

- `flutter_riverpod`, `dio`, `sensors_plus`, `geolocator`, `flutter_blue_plus`, `torch_light`, `camera`, `permission_handler`.

---

This file is a setup guidance note; I won't edit native project files automatically without your confirmation.
