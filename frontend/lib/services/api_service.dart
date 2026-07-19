import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Android Emulator: http://10.0.2.2:8080/api
  // Web/Desktop/iOS Simulator: http://localhost:8080/api
  // HP fisik: ganti 10.0.2.2 dengan IP laptop, contoh http://192.168.1.10:8080/api
  static const String baseUrl = 'http://localhost:8080/api';

  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('REQUEST[${options.method}] => ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('ERROR[${error.response?.statusCode}] => ${error.message}');
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'auth_token');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _requestWithRetry(
      () => _dio.get(path, queryParameters: queryParameters),
    );
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    return _requestWithRetry(() => _dio.post(path, data: data));
  }

  Future<Response<dynamic>> put(String path, {dynamic data}) async {
    return _requestWithRetry(() => _dio.put(path, data: data));
  }

  Future<Response<dynamic>> patch(String path, {dynamic data}) async {
    return _requestWithRetry(() => _dio.patch(path, data: data));
  }

  Future<Response<dynamic>> delete(String path) async {
    return _requestWithRetry(() => _dio.delete(path));
  }

  Future<Response<dynamic>> _requestWithRetry(
    Future<Response<dynamic>> Function() request,
  ) async {
    const maxAttempts = 2;
    DioException? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await request();
      } on DioException catch (error) {
        lastError = error;
        if (!_shouldRetry(error) || attempt == maxAttempts) {
          throw _handleError(error);
        }
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw _handleError(lastError!);
  }

  bool _shouldRetry(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        statusCode >= 500;
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Koneksi timeout. Pastikan backend Spring Boot sudah berjalan.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server. Cek baseUrl, jaringan, dan pastikan backend aktif.';
    }

    final response = error.response;
    if (response != null) {
      final data = response.data;
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      switch (response.statusCode) {
        case 400:
          return 'Data yang dikirim belum valid.';
        case 401:
          return 'Sesi login berakhir. Silakan login ulang.';
        case 403:
          return 'Akses ditolak.';
        case 404:
          return 'Data tidak ditemukan.';
        case 500:
          return 'Server sedang bermasalah. Coba lagi nanti.';
        default:
          return 'Terjadi kesalahan server (${response.statusCode}).';
      }
    }

    return 'Terjadi gangguan jaringan.';
  }
}
