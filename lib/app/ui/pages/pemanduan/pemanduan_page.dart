import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/pemanduan_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/spk_model.dart';

class PemanduanPage extends StatefulWidget {
  const PemanduanPage({super.key});

  @override
  State<PemanduanPage> createState() => _PemanduanPageState();
}

class _PemanduanPageState extends State<PemanduanPage> {
  final PemanduanController _controller = Get.find<PemanduanController>();
  SpkModel? spkData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    // Clear pemanduan data if user navigates back without completing
    if (_controller.hasActivePemanduan) {
      _controller.cancelPemanduan();
    }
    super.dispose();
  }

  void _initializeData() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is SpkModel) {
      spkData = arguments;
      _controller.startPemanduan(arguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pemanduan'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showCancelDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!_controller.hasActivePemanduan) {
          return _buildNoActivePemanduan();
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildSpkInfoCard(),
              _buildWorkflowSteps(),
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNoActivePemanduan() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pemanduan aktif',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan mulai pemanduan dari halaman SPK Detail',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpkInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _controller.currentSpkName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No. SPK: ${_controller.currentSpk.value?.nomorSpk ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AKTIF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Asal: ${_controller.currentSpk.value?.namaLokasiTundaAsal ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Tujuan: ${_controller.currentSpk.value?.namaLokasiTundaTujuan ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowSteps() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proses Pemanduan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children:
                    _controller.workflow.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      final isCompleted = step['status'] as bool;
                      final isLast = index == _controller.workflow.length - 1;

                      return IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          isCompleted
                                              ? Colors.green
                                              : Colors.grey[300],
                                      border: Border.all(
                                        color:
                                            isCompleted
                                                ? Colors.green
                                                : Colors.grey[400]!,
                                        width: 3,
                                      ),
                                    ),
                                    child: Center(
                                      child:
                                          isCompleted
                                              ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 24,
                                              )
                                              : Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      isCompleted
                                                          ? Colors.white
                                                          : Colors.grey[600],
                                                  fontSize: 16,
                                                ),
                                              ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    step['title'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isCompleted
                                              ? Colors.green
                                              : Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (isCompleted &&
                                      step['value'] != '00:00:00')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        step['value'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  height: 3,
                                  color:
                                      isCompleted
                                          ? Colors.green
                                          : Colors.grey[300],
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Obx(() {
            final allStepsCompleted = _controller.workflow.every(
              (step) => step['status'] as bool,
            );

            if (allStepsCompleted) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showFinishDialog,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    'SELESAIKAN PEMANDUAN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children:
                  _controller.workflow
                      .where((step) => !(step['status'] as bool))
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Show loading indicator
                                _showLoadingDialog('Menyimpan progress...');

                                // Execute step
                                await _controller.executeStep(
                                  step['id'] as String,
                                );

                                // Close loading dialog
                                Get.back();

                                // Show success feedback
                                Get.snackbar(
                                  'Berhasil',
                                  '${step['title']} telah dicatat',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              icon: Icon(
                                step['id'] == 'tug_fast'
                                    ? Icons.play_arrow
                                    : Icons.stop,
                                color: Colors.white,
                              ),
                              label: Text(
                                (step['id'] as String).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D47A1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            );
          }),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Batalkan Pemanduan'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pemanduan ini?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('TIDAK')),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.cancelPemanduan();
              Get.back(); // Go back to previous page
            },
            child: const Text('YA'),
          ),
        ],
      ),
    );
  }

  void _showFinishDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Selesaikan Pemanduan'),
        content: const Text(
          'Apakah Anda yakin ingin menyelesaikan pemanduan ini?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('TIDAK')),
          Obx(
            () => TextButton(
              onPressed:
                  _controller.isLoading.value
                      ? null
                      : () async {
                        Get.back();

                        // Show loading dialog
                        _showLoadingDialog('Menyelesaikan pemanduan...');

                        final success = await _controller.finishPemanduan();

                        // Close loading dialog
                        Get.back();

                        if (success) {
                          Get.back(); // Go back to previous page
                          Get.snackbar(
                            'Berhasil',
                            'Pemanduan telah diselesaikan',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            _controller.errorMessage.value,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 5),
                          );
                        }
                      },
              child:
                  _controller.isLoading.value
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text('YA'),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
