import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("DIO REQ: ${options.method} ${options.path} - Headers: ${options.headers}");
        return handler.next(options);
      },
    ));
  }

  void setToken(String token) {
    print("ApiService.setToken() called with: $token");
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print("Current headers: ${_dio.options.headers}");
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  Future<Response> upload(String path, FormData data) => _dio.post(path, data: data);
}
