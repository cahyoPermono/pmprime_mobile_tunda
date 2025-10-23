import 'package:dio/dio.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/api_response.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/providers/base_provider.dart';

class SpkProvider extends BaseProvider {

  SpkProvider() : super() {
    // Specific configurations for SpkProvider if any
    // super.dio.options.validateStatus = (status) => status! < 500;
  }

  /// Load SPK data by Notification
  Future<ApiResponse> loadSpkData(String notifId) async {
    try {
      final response = await super.dio.get('/surat_perintah_kerja_pandu/$notifId');
      if (response.statusCode == 200) {
        return ApiResponse.success(data: response.data);
      } else {
        return ApiResponse.error(message: 'Failed to load SPK data');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Load SPK details by ID
  Future<ApiResponse> loadSpkDetails(String id) async {
    try {
      final response = await super.dio.get('/surat_perintah_kerja_tunda/$id');
      if (response.statusCode == 200) {
        return ApiResponse.success(data: response.data);
      } else {
        return ApiResponse.error(message: 'Failed to load SPK details');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Load SPK realization data by date range
  Future<ApiResponse> loadSpkRealization(
    String startDate,
    String endDate,
    String username,
  ) async {
    try {
      final response = await super.dio.get(
        '/progress_spk/kode_kapal_tunda/$username',
        queryParameters: {'tglMulai': startDate, 'tglSelesai': endDate},
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(data: response.data);
      } else {
        return ApiResponse.error(message: 'Failed to load SPK realization');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Load history realization by date range with filters
  Future<ApiResponse> loadHistoryRealization(
    String startDate,
    String endDate,
    String username, {
    String? jenisJasa,
    int? flagDone,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'tglMulai': startDate,
        'tglSelesai': endDate,
      };

      if (jenisJasa != null) queryParams['jenisJasa'] = jenisJasa;
      if (flagDone != null) queryParams['flagDone'] = flagDone.toString();

      final response = await super.dio.get(
        '/progress_spk/kode_kapal_tunda/$username',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(data: response.data);
      } else {
        return ApiResponse.error(message: 'Failed to load history realization');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Load history by SPK number
  Future<ApiResponse> loadHistoryBySpk(String noSpk) async {
    try {
      final response = await super.dio.get('/progress_spk/nomor_spk/$noSpk');

      if (response.statusCode == 200) {
        return ApiResponse.success(data: response.data);
      } else {
        return ApiResponse.error(message: 'Failed to load SPK history');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Post progress update
  Future<ApiResponse> postProgress({
    required int idTahapanPandu,
    required String nomorSpk,
    required String nomorSpkTunda,
    required String tglTahapan,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'idTahapanPandu': idTahapanPandu,
        'nomorSpk': nomorSpk,
        'nomorSpkTunda': nomorSpkTunda,
        'tglTahapan': tglTahapan,
      };

      final response = await super.dio.post('/progress_spk', data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          data: response.data,
          message: 'Progress updated successfully',
        );
      } else {
        return ApiResponse.error(message: 'Failed to update progress');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Mark progress as done
  Future<ApiResponse> markProgressAsDone(String id) async {
    try {
      final response = await super.dio.put(
        '/progress_spk/spk_tunda/$id/set_as_done',
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: response.data,
          message: 'Progress marked as done',
        );
      } else {
        return ApiResponse.error(message: 'Failed to mark progress as done');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Load progress by Pandu SPK number
  Future<ApiResponse> loadProgressByPanduSpk(String nomorSpkPandu) async {
    try {
      final response = await super.dio.get('/progress_spk/nomor_spk/$nomorSpkPandu');

      if (response.statusCode == 200) {
        return ApiResponse.success(data: response.data);
      } else {
        return ApiResponse.error(message: 'Failed to load Pandu progress');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Post engine status
  Future<ApiResponse> postEngineStatus(Map<String, dynamic> engineData) async {
    try {
      final response = await super.dio.post(
        '/tunda/status_engine_kapal',
        data: engineData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          data: response.data,
          message: 'Engine status updated',
        );
      } else {
        return ApiResponse.error(message: 'Failed to update engine status');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Post bulk progress data
  Future<ApiResponse> postBulkProgress(
    Map<String, dynamic> progressData,
  ) async {
    try {
      final response = await super.dio.post('/kinerja_tunda', data: progressData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          data: response.data,
          message: 'Bulk progress posted',
        );
      } else {
        return ApiResponse.error(message: 'Failed to post bulk progress');
      }
    } on DioException catch (e) {
      return super.handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
