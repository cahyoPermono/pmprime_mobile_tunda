import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/engine_controller.dart';

class EngineStatusPage extends GetView<EngineController> {
  const EngineStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Engine Control',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _StatusIndicator(
                      status: controller.currentStatus.value,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => _EngineToggleButton(
                      status: controller.currentStatus.value,
                      onTap: () {
                        if (controller.currentStatus.value == 'OFF') {
                          controller.turnOnEngine();
                        } else {
                          controller.turnOffEngine();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => Text(
                      'Last Update: ${controller.lastUpdate.value}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isEngineOn = status == 'ON';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEngineOn ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEngineOn ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEngineOn ? Colors.green : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: (isEngineOn ? Colors.green : Colors.red).withValues(
                    alpha: 0.5,
                  ),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Status: $status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isEngineOn ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineToggleButton extends StatelessWidget {
  final String status;
  final VoidCallback onTap;

  const _EngineToggleButton({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isEngineOn = status == 'ON';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEngineOn ? Colors.green : Colors.red,
          boxShadow: [
            BoxShadow(
              color: (isEngineOn ? Colors.green : Colors.red).withValues(
                alpha: 0.4,
              ),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.power_settings_new, size: 70, color: Colors.white),
        ),
      ),
    );
  }
}
