/// TorchService: lightweight stub that can be replaced with a real implementation
/// (e.g., the `torch_light` package or CameraController flash mode toggling).
class TorchService {
  Future<void> turnOn() async {
    // No-op fallback for platforms where torch plugin isn't available in this branch.
    return Future.value();
  }

  Future<void> turnOff() async {
    return Future.value();
  }
}
