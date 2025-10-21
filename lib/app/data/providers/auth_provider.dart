import 'package:dio/dio.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/api_response.dart';

class AuthProvider {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://pmprime.imaniprima.co.id/api/mobile';

  AuthProvider() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors for logging, auth tokens, etc.
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<ApiResponse> login(String kodeKapal, String kodeCabang) async {
    try {
      final response = await _dio.get(
        '/tunda/profil_kapal/$kodeKapal/cabang/$kodeCabang',
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data.isNotEmpty) {
        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Login berhasil',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Kode Registrasi Kapal atau Kode Cabang tidak ditemukan',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan koneksi';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Koneksi timeout';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }

      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
