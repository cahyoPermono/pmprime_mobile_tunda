import 'package:get/get.dart';

class EngineController extends GetxController {
  final RxString currentStatus = 'OFF'.obs;
  final RxString lastUpdate = 'Never'.obs;

  @override
  void onInit() {
    super.onInit();
    loadEngineStatus();
  }

  Future<void> loadEngineStatus() async {
    // TODO: Load from storage or API
    currentStatus.value = 'OFF';
    lastUpdate.value = 'Never';
  }

  Future<void> turnOnEngine() async {
    // TODO: Implement API call to turn on engine
    currentStatus.value = 'ON';
    lastUpdate.value = DateTime.now().toString();
  }

  Future<void> turnOffEngine() async {
    // TODO: Show reason dialog and implement API call
    currentStatus.value = 'OFF';
    lastUpdate.value = DateTime.now().toString();
  }

  void handleEngineOffCommand(dynamic data) {
    // Handle MQTT command to turn off engine
    currentStatus.value = 'OFF';
    lastUpdate.value = DateTime.now().toString();
  }

  void handleEngineOnCommand(dynamic data) {
    // Handle MQTT command to turn on engine
    currentStatus.value = 'ON';
    lastUpdate.value = DateTime.now().toString();
  }
}
