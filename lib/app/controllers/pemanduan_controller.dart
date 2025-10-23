import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/spk_model.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/providers/spk_provider.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/storage_service.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/mqtt_service.dart';
import 'package:intl/intl.dart';

class PemanduanController extends GetxController {
  final SpkProvider _spkProvider = SpkProvider();
  final StorageService _storageService = Get.find<StorageService>();
  final MqttService _mqttService = Get.find<MqttService>();

  // Workflow steps for tug operations
  final List<Map<String, dynamic>> _workflowSteps = [
    {
      'id': 'tug_fast',
      'title': 'Tug Fast',
      'tahapPandu': 8,
      'status': false,
      'value': '00:00:00',
    },
    {
      'id': 'tug_off',
      'title': 'Tug Off',
      'tahapPandu': 9,
      'status': false,
      'value': '00:00:00',
    },
  ];

  // Reactive variables
  final Rx<SpkModel?> currentSpk = Rx<SpkModel?>(null);
  final RxList<Map<String, dynamic>> workflow = <Map<String, dynamic>>[].obs;
  final RxString currentStep = ''.obs;
  final RxString htmlText = ''.obs;
  final RxString timeDiff = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Timer variables
  final RxString tugFastTime = '00:00:00'.obs;
  final RxString tugOffTime = '00:00:00'.obs;
  final RxBool isTugFast = false.obs;
  final RxBool isTugOff = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeWorkflow();
  }

  void _initializeWorkflow() {
    workflow.assignAll(List<Map<String, dynamic>>.from(_workflowSteps));
  }

  Future<bool> startPemanduan(SpkModel spk) async {
    try {
      isLoading.value = true;

      // Check if there's already an ongoing pemanduan
      final existingPanduid = await _storageService.getPanduid();
      if (existingPanduid != null && existingPanduid != spk.id) {
        errorMessage.value = 'Anda memiliki pekerjaan yang belum terselesaikan';
        return false;
      }

      // Set current SPK and panduid
      currentSpk.value = spk;
      await _storageService.setPanduid(spk.id!);

      // Reset workflow
      _initializeWorkflow();
      currentStep.value = 'pemanduan_start';
      htmlText.value = '';

      // Subscribe to progress topic for monitoring
      if (spk.nomorSpkPandu != null) {
        _mqttService.subscribeToProgressTopic(spk.nomorSpkPandu!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error starting pemanduan: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> executeStep(String stepId) async {
    try {
      if (currentSpk.value == null) return;

      final stepIndex = workflow.indexWhere((step) => step['id'] == stepId);
      if (stepIndex == -1) return;

      // Update step status and time
      final now = DateFormat('HH:mm:ss').format(DateTime.now());

      // Update workflow step
      final updatedStep = Map<String, dynamic>.from(workflow[stepIndex]);
      updatedStep['status'] = true;
      updatedStep['value'] = now;

      workflow[stepIndex] = updatedStep;

      // Update reactive variables for UI
      if (stepId == 'tug_fast') {
        isTugFast.value = true;
        tugFastTime.value = now;
      } else if (stepId == 'tug_off') {
        isTugOff.value = true;
        tugOffTime.value = now;
      }

      // Update current step
      if (stepIndex + 1 < workflow.length) {
        currentStep.value = workflow[stepIndex + 1]['id'];
      } else {
        currentStep.value = 'keluar';
      }

      // Add to status template
      _addStatusTemplate(updatedStep['title'], now, updatedStep['tahapPandu']);

      // Calculate time difference if applicable
      if (stepIndex > 0) {
        _calculateTimeDiff(workflow[stepIndex - 1]['value'], now);
      }

      // Post progress to API
      await _postProgress(stepId);

      // Save state to storage
      await _saveWorkflowState();
    } catch (e) {
      errorMessage.value = 'Error executing step: ${e.toString()}';
    }
  }

  void _addStatusTemplate(String title, String value, int tahapPandu) {
    final statusHtml = '''
      <div class="ps_stat_left">
        $title
      </div>
      <div class="ps_stat_right">
        $value
      </div>
    ''';

    htmlText.value += statusHtml;
  }

  void _calculateTimeDiff(String startTime, String endTime) {
    try {
      final start = DateFormat('HH:mm:ss').parse(startTime);
      final end = DateFormat('HH:mm:ss').parse(endTime);
      final difference = end.difference(start);

      final hours = difference.inHours.toString().padLeft(2, '0');
      final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

      final diffHtml = '<li><div>$hours:$minutes:$seconds</div></li>';
      timeDiff.value += diffHtml;
    } catch (e) {
      debugPrint('Error calculating time difference: $e');
    }
  }

  Future<void> _postProgress(String stepId) async {
    if (currentSpk.value == null) return;

    try {
      final stepIndex = workflow.indexWhere((step) => step['id'] == stepId);
      if (stepIndex == -1) return;

      final tahapPandu = workflow[stepIndex]['tahapPandu'];
      final now = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

      await _spkProvider.postProgress(
        idTahapanPandu: tahapPandu,
        nomorSpk: currentSpk.value!.nomorSpk ?? '',
        nomorSpkTunda: currentSpk.value!.nomorSpkTunda ?? '',
        tglTahapan: now,
      );
    } catch (e) {
      debugPrint('Error posting progress: $e');
    }
  }

  Future<void> _saveWorkflowState() async {
    try {
      await _storageService.setWorkerData({
        'workflow': workflow,
        'currentStep': currentStep.value,
        'htmlText': htmlText.value,
        'timeDiff': timeDiff.value,
        'tugFastTime': tugFastTime.value,
        'tugOffTime': tugOffTime.value,
        'isTugFast': isTugFast.value,
        'isTugOff': isTugOff.value,
      });
    } catch (e) {
      debugPrint('Error saving workflow state: $e');
    }
  }

  Future<void> loadWorkflowState() async {
    try {
      final savedData = await _storageService.getWorkerData();
      if (savedData != null) {
        workflow.assignAll(
          List<Map<String, dynamic>>.from(savedData['workflow']),
        );
        currentStep.value = savedData['currentStep'] ?? '';
        htmlText.value = savedData['htmlText'] ?? '';
        timeDiff.value = savedData['timeDiff'] ?? '';
        tugFastTime.value = savedData['tugFastTime'] ?? '00:00:00';
        tugOffTime.value = savedData['tugOffTime'] ?? '00:00:00';
        isTugFast.value = savedData['isTugFast'] ?? false;
        isTugOff.value = savedData['isTugOff'] ?? false;
      }
    } catch (e) {
      debugPrint('Error loading workflow state: $e');
    }
  }

  Future<bool> finishPemanduan() async {
    try {
      if (currentSpk.value == null) return false;

      // Show loading in UI
      isLoading.value = true;

      // Post bulk progress data first
      final bulkData = {
        'flagBatal': false,
        'kodeKapalTunda': currentSpk.value!.kodeKapal ?? '',
        'noPpk1': currentSpk.value!.noPpk1 ?? '',
        'noPpkJasaPandu': currentSpk.value!.noPpkJasaPandu ?? '',
        'noPpkJasaTunda': currentSpk.value!.noPpkJasa ?? '',
        'nomorSpkTunda': currentSpk.value!.nomorSpkTunda ?? '',
        'nomorSpkPandu': currentSpk.value!.nomorSpkPandu ?? '',
        'waktuTugFast': '2024-01-01T${tugFastTime.value}',
        'waktuTugOff': '2024-01-01T${tugOffTime.value}',
      };

      debugPrint('Posting bulk progress data: $bulkData');
      final bulkResult = await _spkProvider.postBulkProgress(bulkData);

      if (!bulkResult.success) {
        errorMessage.value =
            'Failed to post bulk progress: ${bulkResult.message}';
        return false;
      }

      // Mark as done in API
      debugPrint('Marking progress as done for ID: ${currentSpk.value!.id}');
      final result = await _spkProvider.markProgressAsDone(
        currentSpk.value!.id!,
      );

      if (result.success) {
        // Clear workflow data
        await _storageService.clearPemanduanData();

        // Unsubscribe from progress topic
        if (currentSpk.value!.nomorSpkPandu != null) {
          _mqttService.unsubscribeFromProgressTopic(
            currentSpk.value!.nomorSpkPandu!,
          );
        }

        // Clear current SPK
        currentSpk.value = null;
        _initializeWorkflow();

        return true;
      } else {
        errorMessage.value =
            'Failed to mark progress as done: ${result.message}';
        return false;
      }
    } catch (e) {
      debugPrint('Error in finishPemanduan: $e');
      errorMessage.value = 'Error finishing pemanduan: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelPemanduan() async {
    try {
      // Clear workflow data
      await _storageService.clearPemanduanData();

      // Unsubscribe from progress topic
      if (currentSpk.value?.nomorSpkPandu != null) {
        _mqttService.unsubscribeFromProgressTopic(
          currentSpk.value!.nomorSpkPandu!,
        );
      }

      // Clear current SPK
      currentSpk.value = null;
      _initializeWorkflow();
    } catch (e) {
      debugPrint('Error canceling pemanduan: $e');
    }
  }

  // Getters
  bool get hasActivePemanduan => currentSpk.value != null;
  String get currentSpkId => currentSpk.value?.id ?? '';
  String get currentSpkName => currentSpk.value?.namaKapal ?? '';
}
