import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/main_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/spk_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/auth_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SpkController spkController = Get.find<SpkController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_getAppBarTitle(controller.selectedIndex.value))),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: _buildDrawer(authController),
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

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Engine Status';
      case 1:
        return 'Pelayanan';
      case 2:
        return 'Monitoring';
      default:
        return 'VASA Mobile';
    }
  }

  Widget _buildDrawer(AuthController authController) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.orange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Text(
                    authController.currentUser.value?.namaKapal ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    authController.currentUser.value?.fullUsername ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: const Text('Engine Status'),
            onTap: () {
              controller.changePage(0);
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Pelayanan'),
            onTap: () {
              controller.changePage(1);
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Monitoring'),
            onTap: () {
              controller.changePage(2);
              Get.back();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Get.back();
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back();
              final AuthController authController = Get.find<AuthController>();
              authController.logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
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
