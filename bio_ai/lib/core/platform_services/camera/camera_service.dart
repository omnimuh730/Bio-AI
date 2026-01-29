import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? _controller;
  CameraDescription? _camera;

  Future<void> initialize({
    ResolutionPreset preset = ResolutionPreset.medium,
  }) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception('No cameras available');
    _camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(_camera!, preset);
    await _controller!.initialize();
  }

  bool get isInitialized => _controller?.value.isInitialized == true;

  Future<File> takePhoto({String? filename}) async {
    if (!isInitialized) await initialize();
    final XFile xfile = await _controller!.takePicture();
    final bytes = await xfile.readAsBytes();
    final dir = await _localStorageDir();
    final outName =
        filename ?? 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final outFile = File('${dir.path}/$outName');
    await outFile.writeAsBytes(bytes);
    return outFile;
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  Future<Directory> _localStorageDir() async {
    final d = await getApplicationDocumentsDirectory();
    final up = Directory('${d.path}/uploads');
    if (!await up.exists()) await up.create(recursive: true);
    return up;
  }
}
