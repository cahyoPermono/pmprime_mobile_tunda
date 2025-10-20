import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/bindings/initial_binding.dart';
import 'package:vasa_mobile_tunda_flutter/app/routes/app_pages.dart';
import 'package:vasa_mobile_tunda_flutter/app/routes/app_routes.dart';
import 'package:vasa_mobile_tunda_flutter/app/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await Get.putAsync<StorageService>(() async {
    final storageService = StorageService();
    await storageService.init();
    return storageService;
  });

  runApp(const VasaMobileTundaApp());
}

class VasaMobileTundaApp extends StatelessWidget {
  const VasaMobileTundaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vasa Mobile Tunda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange,
          secondary: Colors.blue,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialBinding: InitialBinding(),
      initialRoute: Routes.login,
      getPages: AppPages.routes,
    );
  }
}
