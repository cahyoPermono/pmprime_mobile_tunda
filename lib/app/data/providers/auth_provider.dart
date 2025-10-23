import 'package:dio/dio.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/api_response.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/providers/base_provider.dart';

class AuthProvider extends BaseProvider {

  AuthProvider() : super() {
    // Specific configurations for AuthProvider if any, otherwise can be empty
    // For example, if auth needs a different base URL or interceptors
    // super.dio.options.baseUrl = 'http://some-other-url.com';
  }

  Future<ApiResponse> login(String kodeKapal, String kodeCabang) async {
    try {
      final response = await super.dio.get(
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
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
