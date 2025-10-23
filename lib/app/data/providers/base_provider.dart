import 'package:dio/dio.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/api_response.dart';

class BaseProvider {
  late Dio _dio;

  BaseProvider() {
    _dio = Dio();
    _dio.options.baseUrl = 'http://pmprime.imaniprima.co.id/api/mobile'; // Base URL for all APIs
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.headers = {'Content-Type': 'application/json'};
    _dio.options.validateStatus = (status) => status! < 500; // Treat 5xx as errors

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Dio get dio => _dio;

  ApiResponse handleDioError(DioException e) {
    String errorMessage = 'Terjadi kesalahan jaringan.'; // Default generic message

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Koneksi timeout. Mohon coba lagi.';
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      // Handle 5xx server errors
      if (statusCode != null && statusCode >= 500) {
        errorMessage = 'Sistem sedang dalam perbaikan, mohon coba beberapa saat lagi.';
      } else {
        // Other bad responses (e.g., 4xx)
        errorMessage = e.response?.data['message'] ?? 'Terjadi kesalahan pada server.';
      }
    } else if (e.type == DioExceptionType.unknown) {
      errorMessage = 'Tidak dapat terhubung ke server. Mohon periksa koneksi internet Anda.';
    }

    return ApiResponse.error(message: errorMessage);
  }
}
