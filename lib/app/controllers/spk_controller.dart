import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/providers/spk_provider.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/spk_model.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/storage_service.dart';
import 'package:intl/intl.dart';

class SpkController extends GetxController {
  final SpkProvider _spkProvider = SpkProvider();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final RxList<SpkModel> spkList = <SpkModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt badgeCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSpkData();
  }

  Future<void> loadSpkData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final username = await _storageService.getUsername();
      if (username == null) {
        errorMessage.value = 'User not logged in';
        return;
      }

      // Calculate date range (3 days back to today)
      final startDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().subtract(const Duration(days: 3)));
      final endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final result = await _spkProvider.loadSpkRealization(
        startDate,
        endDate,
        username,
      );

      if (result.success && result.data != null) {
        final List<SpkModel> spks = [];
        for (var item in result.data) {
          spks.add(SpkModel.fromJson(item));
        }

        spkList.assignAll(spks);
        await _storageService.saveSpkList(spks);

        // Update badge count
        _updateBadgeCount();
      } else {
        errorMessage.value = result.message ?? 'Failed to load SPK data';

        // Try to load from cache
        await _loadFromCache();
      }
    } catch (e) {
      errorMessage.value = 'Error loading SPK data: ${e.toString()}';

      // Try to load from cache
      await _loadFromCache();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedSpks = await _storageService.getSpkList();
      if (cachedSpks.isNotEmpty) {
        spkList.assignAll(cachedSpks);
        _updateBadgeCount();
      }
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    }
  }

  void _updateBadgeCount() {
    final pendingCount = spkList.where((spk) => spk.isPending).length;
    final ongoingCount = spkList.where((spk) => spk.isOnGoing).length;
    badgeCount.value = pendingCount + ongoingCount;
  }

  Future<SpkModel?> loadSpkDetails(String id) async {
    try {
      final result = await _spkProvider.loadSpkDetails(id);

      if (result.success && result.data != null) {
        return SpkModel.fromJson(result.data);
      } else {
        errorMessage.value = result.message ?? 'Failed to load SPK details';
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Error loading SPK details: ${e.toString()}';
      return null;
    }
  }

  Future<bool> startPemanduan(String spkId) async {
    try {
      // Check if there's already an ongoing pemanduan
      final currentPanduid = await _storageService.getPanduid();
      if (currentPanduid != null) {
        errorMessage.value = 'Anda memiliki pekerjaan yang belum terselesaikan';
        return false;
      }

      // Set panduid to start pemanduan
      await _storageService.setPanduid(spkId);

      // Update SPK status to ongoing
      final spkIndex = spkList.indexWhere((spk) => spk.id == spkId);
      if (spkIndex != -1) {
        // Create a copy with updated status
        final updatedSpk = SpkModel(
          id: spkList[spkIndex].id,
          namaKapal: spkList[spkIndex].namaKapal,
          namaAgen: spkList[spkIndex].namaAgen,
          noPpk1: spkList[spkIndex].noPpk1,
          nomorSpk: spkList[spkIndex].nomorSpk,
          noPpkJasa: spkList[spkIndex].noPpkJasa,
          asal: spkList[spkIndex].asal,
          tujuan: spkList[spkIndex].tujuan,
          namaLokasiTundaAsal: spkList[spkIndex].namaLokasiTundaAsal,
          namaLokasiTundaTujuan: spkList[spkIndex].namaLokasiTundaTujuan,
          nomorSpkTunda: spkList[spkIndex].nomorSpkTunda,
          nomorSpkPandu: spkList[spkIndex].nomorSpkPandu,
          noPpkJasaPandu: spkList[spkIndex].noPpkJasaPandu,
          tglPelayananTunda: spkList[spkIndex].tglPelayananTunda,
          flagDone: 1, // Set to ongoing
          kodeKapal: spkList[spkIndex].kodeKapal,
          kodeCabang: spkList[spkIndex].kodeCabang,
          username: spkList[spkIndex].username,
        );

        spkList[spkIndex] = updatedSpk;
        _updateBadgeCount();
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error starting pemanduan: ${e.toString()}';
      return false;
    }
  }

  Future<bool> finishPemanduan(String spkId) async {
    try {
      final result = await _spkProvider.markProgressAsDone(spkId);

      if (result.success) {
        // Clear pemanduan data
        await _storageService.clearPemanduanData();

        // Update SPK status to finished
        final spkIndex = spkList.indexWhere((spk) => spk.id == spkId);
        if (spkIndex != -1) {
          final updatedSpk = SpkModel(
            id: spkList[spkIndex].id,
            namaKapal: spkList[spkIndex].namaKapal,
            namaAgen: spkList[spkIndex].namaAgen,
            noPpk1: spkList[spkIndex].noPpk1,
            nomorSpk: spkList[spkIndex].nomorSpk,
            noPpkJasa: spkList[spkIndex].noPpkJasa,
            asal: spkList[spkIndex].asal,
            tujuan: spkList[spkIndex].tujuan,
            namaLokasiTundaAsal: spkList[spkIndex].namaLokasiTundaAsal,
            namaLokasiTundaTujuan: spkList[spkIndex].namaLokasiTundaTujuan,
            nomorSpkTunda: spkList[spkIndex].nomorSpkTunda,
            nomorSpkPandu: spkList[spkIndex].nomorSpkPandu,
            noPpkJasaPandu: spkList[spkIndex].noPpkJasaPandu,
            tglPelayananTunda: spkList[spkIndex].tglPelayananTunda,
            flagDone: 2, // Set to finished
            kodeKapal: spkList[spkIndex].kodeKapal,
            kodeCabang: spkList[spkIndex].kodeCabang,
            username: spkList[spkIndex].username,
          );

          spkList[spkIndex] = updatedSpk;
          _updateBadgeCount();
        }

        return true;
      } else {
        errorMessage.value = result.message ?? 'Failed to finish pemanduan';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error finishing pemanduan: ${e.toString()}';
      return false;
    }
  }

  void refreshData() {
    loadSpkData();
  }

  void clearBadge() {
    badgeCount.value = 0;
  }

  // Getters
  List<SpkModel> get pendingSpks =>
      spkList.where((spk) => spk.isPending).toList();
  List<SpkModel> get ongoingSpks =>
      spkList.where((spk) => spk.isOnGoing).toList();
  List<SpkModel> get finishedSpks =>
      spkList.where((spk) => spk.isFinished).toList();
}
