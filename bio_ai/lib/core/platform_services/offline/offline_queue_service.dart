import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:bio_ai/core/platform_services/network/network_service.dart';

class OfflineQueueService {
  final NetworkService _network;
  OfflineQueueService({required NetworkService network}) : _network = network;

  Future<Directory> _queueDir() async {
    final d = await getApplicationDocumentsDirectory();
    final q = Directory('${d.path}/uploads/offline');
    if (!await q.exists()) await q.create(recursive: true);
    return q;
  }

  Future<File> queueFile(File file, {Map<String, dynamic>? meta}) async {
    final q = await _queueDir();
    final dest = File(p.join(q.path, p.basename(file.path)));
    await file.copy(dest.path);
    final metaFile = File('${dest.path}.meta.json');
    await metaFile.writeAsString(
      jsonEncode(meta ?? {'queued_at': DateTime.now().toIso8601String()}),
    );
    return dest;
  }

  Future<List<File>> pendingFiles() async {
    final q = await _queueDir();
    final files = q
        .listSync()
        .whereType<File>()
        .where((f) => !f.path.endsWith('.meta.json'))
        .toList();
    return files;
  }

  Future<void> flushQueue() async {
    final files = await pendingFiles();
    for (final f in files) {
      try {
        // naive upload example
        final res = await _network.post('/upload', {'file_path': f.path});
        if (res.statusCode == 200 || res.statusCode == 201) {
          // remove file and its meta
          final meta = File('${f.path}.meta.json');
          if (await f.exists()) await f.delete();
          if (await meta.exists()) await meta.delete();
        }
      } catch (_) {
        // keep in queue
      }
    }
  }
}
