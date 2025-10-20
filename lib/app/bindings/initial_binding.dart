import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/auth_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/main_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/engine_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/spk_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/pemanduan_controller.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/storage_service.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/mqtt_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services first
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<MqttService>(() => MqttService(), fenix: true);

    // Initialize controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
    Get.lazyPut<EngineController>(() => EngineController(), fenix: true);
    Get.lazyPut<SpkController>(() => SpkController(), fenix: true);
    Get.lazyPut<PemanduanController>(() => PemanduanController(), fenix: true);
  }
}
