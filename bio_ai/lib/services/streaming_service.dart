import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:bio_ai/core/config.dart';

class StreamingService {
  // Simple singleton
  StreamingService._private();
  static final StreamingService instance = StreamingService._private();

  final Dio _dio = Dio();
  Timer? _timer;
  final ValueNotifier<Map<String, dynamic>> latest = ValueNotifier({});
  String? selectedDeviceName;

  void start() {
    if (!AppConfig.isDevOrStage) return;
    // poll every second
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void setSelectedDevice(String? name) {
    selectedDeviceName = name;
    // no network call required; dashboard will use this when rendering
  }

  Future<void> _poll() async {
    try {
      final res = await _dio.get('${AppConfig.streamingBaseUrl}/api/latest');
      if (res.statusCode == 200 && res.data != null) {
        final List items = res.data['latest'] ?? [];
        // reduce to a map by device name
        final Map<String, dynamic> m = {};
        for (var it in items) {
          m[it['device']] = it;
        }
        latest.value = m;
      }
    } catch (e) {
      // ignore network errors silently for now
    }
  }

  void dispose() {
    stop();
    latest.dispose();
  }
}
