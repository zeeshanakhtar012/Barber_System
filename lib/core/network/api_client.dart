import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:barber_saas/data/providers/storage_provider.dart';

class ApiClient extends GetxService {
  late Dio dio;
  final StorageProvider _storage = Get.find<StorageProvider>();

  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator
  static final String baseUrl = GetPlatform.isAndroid
      ? 'http://10.0.2.2:5001/api'
      : 'http://localhost:5001/api';

  Future<ApiClient> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = await _storage.getSession();
          if (session != null && session.containsKey('token')) {
            options.headers['Authorization'] = 'Bearer ${session['token']}';
          }
          debugPrint('🚀 [API Request] ${options.method} ➔ ${options.uri}');
          if (options.data != null) {
            debugPrint('📦 Request Body: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '✅ [API Response] ${response.statusCode} ➔ ${response.requestOptions.uri}',
          );
          debugPrint('💬 Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint(
            '❌ [API Error] ${e.response?.statusCode ?? "Unknown Code"} ➔ ${e.requestOptions.uri}',
          );
          if (e.response?.data != null) {
            debugPrint('💬 Error Response Data: ${e.response?.data}');
          } else {
            debugPrint('⚠️ Error Message: ${e.message}');
          }
          return handler.next(e);
        },
      ),
    );

    return this;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
