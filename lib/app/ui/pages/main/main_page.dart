import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/main_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/spk_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SpkController spkController = Get.find<SpkController>();

    return Scaffold(
      body: Obx(() => controller.pages[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changePage,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.engineering),
              label: 'ENGINE',
            ),
            BottomNavigationBarItem(
              icon: _buildSpkIcon(spkController),
              label: 'PELAYANAN',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'MAP'),
          ],
        ),
      ),
    );
  }

  Widget _buildSpkIcon(SpkController spkController) {
    return Stack(
      children: [
        const Icon(Icons.assignment),
        if (spkController.badgeCount.value > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                spkController.badgeCount.value > 99
                    ? '99+'
                    : spkController.badgeCount.value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
