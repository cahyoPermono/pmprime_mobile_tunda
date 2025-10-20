import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/engine_controller.dart';

class EngineStatusPage extends GetView<EngineController> {
  const EngineStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/tundatop.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
            const Text('ENGINE'),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Start / Off Duty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Obx(
              () => Text(
                'Current Status: ${controller.currentStatus.value}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                'Last Update: ${controller.lastUpdate.value}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        controller.currentStatus.value == 'OFF'
                            ? controller.turnOnEngine
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('ON'),
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        controller.currentStatus.value == 'ON'
                            ? controller.turnOffEngine
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('OFF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
