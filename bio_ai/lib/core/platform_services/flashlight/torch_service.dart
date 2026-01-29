import 'package:torch_light/torch_light.dart';

class TorchService {
  Future<void> turnOn() async {
    try {
      await TorchLight.enableTorch();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> turnOff() async {
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      rethrow;
    }
  }
}
