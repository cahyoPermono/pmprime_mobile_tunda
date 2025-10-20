import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/providers/auth_provider.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/user_model.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/storage_service.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/mqtt_service.dart';
import 'package:vasa_mobile_tunda_flutter/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();
  final StorageService _storageService = Get.find<StorageService>();
  final MqttService _mqttService = Get.find<MqttService>();

  // Form controllers
  final TextEditingController kodeKapalController = TextEditingController();
  final TextEditingController kodeCabangController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    checkAuthStatus();
  }

  @override
  void onClose() {
    kodeKapalController.dispose();
    kodeCabangController.dispose();
    super.onClose();
  }

  Future<void> checkAuthStatus() async {
    try {
      final hasLoggedIn = await _storageService.hasLoggedIn();
      if (hasLoggedIn) {
        final profileData = await _storageService.getProfileData();
        if (profileData != null) {
          currentUser.value = UserModel.fromJson(profileData);
          // Initialize MQTT connection
          await _initializeMqtt();
          // Navigate to main page if already logged in
          Get.offAllNamed(Routes.main);
        }
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }
  }

  Future<void> _initializeMqtt() async {
    if (currentUser.value != null) {
      final connected = await _mqttService.connect(
        currentUser.value!.fullUsername,
      );
      if (connected) {
        debugPrint('MQTT connected successfully');
      }
    }
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final kodeKapal = kodeKapalController.text.trim();
      final kodeCabang = kodeCabangController.text.trim();

      final result = await _authProvider.login(kodeKapal, kodeCabang);

      if (result.success && result.data != null) {
        // Create user model from response
        final user = UserModel.fromJson(result.data);
        currentUser.value = user;

        // Save authentication state
        await _storageService.setLoggedIn(true);
        await _storageService.setUsername(user.fullUsername);
        await _storageService.setProfileData(result.data);

        // Initialize MQTT connection
        await _initializeMqtt();

        // Clear form
        kodeKapalController.clear();
        kodeCabangController.clear();

        // Navigate to main page
        Get.offAllNamed(Routes.main);
      } else {
        errorMessage.value = result.message ?? 'Login gagal';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      // Clear form
      kodeKapalController.clear();
      kodeCabangController.clear();
      errorMessage.value = '';

      // Disconnect MQTT
      _mqttService.disconnect();

      // Clear stored auth data
      await _storageService.clearAuthData();

      // Clear current user
      currentUser.value = null;

      // Navigate to login page
      Get.offAllNamed(Routes.login);
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Still navigate to login even if there's an error
      Get.offAllNamed(Routes.login);
    }
  }

  bool get isLoggedIn => currentUser.value != null;
}
