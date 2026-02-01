import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/app/di/injectors.dart';

class CaptureCameraBackground extends ConsumerWidget {
  const CaptureCameraBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camInit = ref.watch(cameraInitProvider);
    return camInit.when(
      data: (_) {
        final cam = ref.read(cameraServiceProvider);
        if (cam.controller != null && cam.isInitialized) {
          return CameraPreview(cam.controller!);
        }
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
