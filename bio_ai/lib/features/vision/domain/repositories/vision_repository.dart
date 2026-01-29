import 'dart:io';

abstract class VisionRepository {
  /// Upload a captured photo to server
  Future<void> uploadPhoto(File file, {Map<String, dynamic>? meta});

  /// Queue a captured photo for later upload when offline
  Future<void> queuePhoto(File file, {Map<String, dynamic>? meta});

  /// Attempt to flush queued uploads
  Future<void> flushQueued();
}
