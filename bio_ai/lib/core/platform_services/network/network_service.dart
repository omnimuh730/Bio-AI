import 'package:dio/dio.dart';

class NetworkService {
  final Dio dio;

  NetworkService({Dio? client})
    : dio = client ?? Dio(BaseOptions(connectTimeout: 5000));

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, dynamic data) async {
    return dio.post(path, data: data);
  }
}
