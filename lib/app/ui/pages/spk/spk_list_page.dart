import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/spk_controller.dart';

class SpkListPage extends GetView<SpkController> {
  const SpkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Obx(
        () => controller.isLoading.value && controller.spkList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _buildSpkList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.refreshData,
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildSpkList() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: Obx(() => controller.spkList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.spkList.length,
              itemBuilder: (context, index) {
                final spk = controller.spkList[index];
                return _buildSpkCard(spk);
              },
            )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_box.png', // Anda perlu menambahkan gambar ini
            width: 150,
            height: 150,
            color: Colors.grey.shade400,
            errorBuilder: (ctx, err, st) =>
                Icon(Icons.inbox_outlined, size: 100, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tidak Ada SPK Tersedia',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
          ),
          const SizedBox(height: 8),
          Text(
            'Saat ini tidak ada Surat Perintah Kerja untuk Anda.\nTarik ke bawah untuk menyegarkan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSpkCard(dynamic spk) {
    final bool isDone = spk.flagDone == 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed('/spk-detail', arguments: spk),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(spk, isDone),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.confirmation_number_outlined, 'No. SPK', spk.nomorSpk ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.article_outlined, 'No. PPK1', spk.noPpk1 ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildRouteInfo(spk),
                  const Divider(height: 24),
                  _buildFooter(spk),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(dynamic spk, bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : const Color(0xFFE3F2FD),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              spk.namaKapal ?? 'Unknown Vessel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDone ? Colors.green.shade800 : const Color(0xFF0D47A1),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _StatusChip(isDone: isDone),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF0D47A1)),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(dynamic spk) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.route_outlined, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asal: ${spk.asal ?? 'N/A'}', style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
              const SizedBox(height: 4),
              Text('Tujuan: ${spk.tujuan ?? 'N/A'}', style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(dynamic spk) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                spk.namaAgen ?? 'Unknown Agent',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1976D2)),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text('Agen', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              spk.formattedTglPelayanan,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1976D2)),
            ),
            const SizedBox(height: 2),
            Text('Tgl Pelayanan', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isDone;

  const _StatusChip({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDone ? Colors.green : Colors.orange.shade700,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        isDone ? 'SELESAI' : 'AKTIF',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}