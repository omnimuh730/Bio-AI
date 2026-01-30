import 'package:dio/dio.dart';
import 'package:bio_ai/core/config.dart';

/// Service for interacting with FatSecret API via bio_ai_server backend
class FatSecretService {
  final Dio _dio;

  FatSecretService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: '$backendBaseUrl/api/vision',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  /// Search for food items by text query
  Future<Map<String, dynamic>> searchFood(
    String query, {
    int maxResults = 20,
  }) async {
    try {
      final response = await _dio.post(
        '/search',
        data: {'query': query, 'max_results': maxResults},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('FatSecret search error: $e');
      return {'error': e.toString()};
    }
  }

  /// Look up food by barcode
  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String region = 'US',
  }) async {
    try {
      final response = await _dio.post(
        '/barcode',
        data: {'barcode': barcode, 'region': region},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('FatSecret barcode lookup error: $e');
      return {'error': e.toString()};
    }
  }

  /// Recognize food in an image file
  Future<Map<String, dynamic>> recognizeImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _dio.post('/recognize', data: formData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('FatSecret image recognition error: $e');
      return {'error': e.toString()};
    }
  }

  /// Upload image and get recognition results (saves to server)
  Future<Map<String, dynamic>> uploadAndRecognize(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _dio.post('/upload', data: formData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('FatSecret upload error: $e');
      return {'error': e.toString()};
    }
  }

  /// Get autocomplete suggestions for food names
  Future<Map<String, dynamic>> autocomplete(String query) async {
    try {
      final response = await _dio.get(
        '/autocomplete',
        queryParameters: {'q': query},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('FatSecret autocomplete error: $e');
      return {'error': e.toString()};
    }
  }

  /// Check API health and connectivity
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('FatSecret health check error: $e');
      return {'ok': false, 'error': e.toString()};
    }
  }
}
