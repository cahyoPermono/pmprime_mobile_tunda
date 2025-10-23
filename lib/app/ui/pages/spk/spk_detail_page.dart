import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/spk_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/spk_model.dart';
import 'package:vasa_mobile_tunda_flutter/app/routes/app_routes.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/storage_service.dart';

class SpkDetailPage extends StatefulWidget {
  const SpkDetailPage({super.key});

  @override
  State<SpkDetailPage> createState() => _SpkDetailPageState();
}

class _SpkDetailPageState extends State<SpkDetailPage> {
  final SpkController _spkController = Get.find<SpkController>();
  final StorageService _storageService = Get.find<StorageService>();

  SpkModel? spkData;
  String startProgressText = '';
  List<Map<String, dynamic>> wizardSteps = [
    {
      'id': 'tug_fast',
      'title': 'Tug Fast',
      'status': false,
      'value': '00:00:00',
    },
    {'id': 'tug_off', 'title': 'Tug Off', 'status': false, 'value': '00:00:00'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final arguments = Get.arguments;
    if (arguments != null && arguments is SpkModel) {
      setState(() {
        spkData = arguments;
        startProgressText =
            arguments.flagDone == 1
                ? 'MULAI KERJAKAN'
                : 'LIHAT HISTORI REALISASI';
      });
    }
    _generateWizardSteps();
  }

  void _generateWizardSteps() {
    setState(() {
      // Reset wizard steps
      wizardSteps = [
        {
          'id': 'tug_fast',
          'title': 'Tug Fast',
          'status': false,
          'value': '00:00:00',
        },
        {
          'id': 'tug_off',
          'title': 'Tug Off',
          'status': false,
          'value': '00:00:00',
        },
      ];
    });
  }

  Future<void> _handlePemanduan() async {
    if (spkData == null) return;

    final currentPanduid = await _storageService.getPanduid();
    if (currentPanduid != null) {
      _showPemanduanConflictDialog();
      return;
    }

    if (spkData!.flagDone == 1) {
      // Start pemanduan
      final success = await _spkController.startPemanduan(spkData!.id!);
      if (success) {
        Get.toNamed(Routes.pemanduan, arguments: spkData);
      } else {
        _showAlertDialog('Error', _spkController.errorMessage.value);
      }
    } else if (spkData!.flagDone == 2) {
      // View history
      Get.toNamed(
        Routes.historyRealisasi,
        arguments: {'data': spkData, 'noSpk': spkData!.nomorSpkTunda},
      );
    }
  }

  void _showAlertDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showPemanduanConflictDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Pemanduan Error !!'),
        content: const Text(
          'Anda memiliki pekerjaan yang belum terselesaikan, mohon selesaikan pemanduan sebelumnya !',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          TextButton(
            onPressed: () {
              Get.back();
              _forceClearPemanduan();
            },
            child: const Text('HAPUS PAKSA'),
          ),
        ],
      ),
    );
  }

  Future<void> _forceClearPemanduan() async {
    try {
      // Clear all pemanduan data from storage
      await _storageService.clearPemanduanData();

      // Show success message
      Get.snackbar(
        'Berhasil',
        'Data pemanduan telah dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus data pemanduan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (spkData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SPK Detail'),
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Data SPK tidak tersedia')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('SPK Detail'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeaderCard(), _buildActionCard()]),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
            // Header with vessel name and agent
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spkData!.namaKapal ?? 'Unknown Vessel',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spkData!.namaAgen ?? 'Unknown Agent',
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
                    color:
                        spkData!.flagDone == 1 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    spkData!.flagDone == 1 ? 'AKTIF' : 'SELESAI',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Service time
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Jam Pelayanan → ${spkData!.formattedTglPelayanan}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),

            const Divider(height: 32),

            // SPK Information Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('PPK1', spkData!.noPpk1 ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoItem('NO. SPK', spkData!.nomorSpk ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoItem('PPK JASA', spkData!.noPpkJasa ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoItem('ASAL', spkData!.asal ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoItem('TUJUAN', spkData!.tujuan ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Wizard Steps
            _buildWizardSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  Widget _buildWizardSteps() {
    return Column(
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children:
                wizardSteps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == wizardSteps.length - 1;

                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      step['status'] as bool
                                          ? Colors.green
                                          : Colors.grey[300],
                                  border: Border.all(
                                    color:
                                        step['status'] as bool
                                            ? Colors.green
                                            : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          step['status'] as bool
                                              ? Colors.white
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                step['title'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.grey[300],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard() {
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
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handlePemanduan,
                icon: Icon(
                  spkData!.flagDone == 1 ? Icons.play_arrow : Icons.history,
                  color: Colors.white,
                ),
                label: Text(
                  startProgressText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
