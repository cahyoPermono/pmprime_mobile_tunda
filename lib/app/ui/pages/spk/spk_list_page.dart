import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/spk_controller.dart';

class SpkListPage extends GetView<SpkController> {
  const SpkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.spkList.isEmpty
                ? _buildEmptyState()
                : _buildSpkList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.refreshData,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada SPK hari ini',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarik ke bawah untuk memuat ulang',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSpkList() {
    return RefreshIndicator(
      onRefresh: () async {
        controller.refreshData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.spkList.length,
        itemBuilder: (context, index) {
          final spk = controller.spkList[index];
          return _buildSpkCard(spk);
        },
      ),
    );
  }

  Widget _buildSpkCard(dynamic spk) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to SPK detail
          Get.toNamed('/spk-detail', arguments: spk);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      spk.flagDone == 1
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  spk.flagDone == 1 ? Icons.play_arrow : Icons.assignment,
                  color: spk.flagDone == 1 ? Colors.green : Colors.blue,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // SPK information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spk.namaKapal ?? 'Unknown Vessel',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PPK1: ${spk.noPpk1 ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'SPK: ${spk.nomorSpk ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Asal: ${spk.asal ?? 'N/A'} → Tujuan: ${spk.tujuan ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      spk.namaAgen ?? 'Unknown Agent',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Time information
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spk.formattedTglPelayanan,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
