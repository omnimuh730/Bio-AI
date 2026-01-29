import 'dart:io';
import 'package:bio_ai/features/vision/domain/repositories/vision_repository.dart';
import 'package:bio_ai/core/platform_services/offline/offline_queue_service.dart';
import 'package:bio_ai/core/platform_services/network/network_service.dart';

class VisionRepositoryImpl implements VisionRepository {
  final NetworkService _network;
  final OfflineQueueService _queue;

  VisionRepositoryImpl({
    required NetworkService network,
    required OfflineQueueService queue,
  }) : _network = network,
       _queue = queue;

  @override
  Future<void> flushQueued() async {
    await _queue.flushQueue();
  }

  @override
  Future<void> queuePhoto(File file, {Map<String, dynamic>? meta}) async {
    await _queue.queueFile(file, meta: meta);
  }

  @override
  Future<void> uploadPhoto(File file, {Map<String, dynamic>? meta}) async {
    // Very naive single-part upload (placeholder). Replace with proper multipart/form-data.
    await _network.post('/upload', {'path': file.path, 'meta': meta ?? {}});
  }
}
