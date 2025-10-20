import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/routes/app_routes.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/auth/login_page.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/main/main_page.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/engine/engine_status_page.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/spk/spk_list_page.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/spk/spk_detail_page.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/pemanduan/pemanduan_page.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/monitoring/monitoring_page.dart';

class AppPages {
  static const initial = Routes.login;

  static final routes = [
    GetPage(name: Routes.login, page: () => const LoginPage()),
    GetPage(name: Routes.main, page: () => const MainPage()),
    GetPage(name: Routes.engineStatus, page: () => const EngineStatusPage()),
    GetPage(name: Routes.spkList, page: () => const SpkListPage()),
    GetPage(name: Routes.spkDetail, page: () => const SpkDetailPage()),
    GetPage(name: Routes.pemanduan, page: () => const PemanduanPage()),
    GetPage(name: Routes.monitoring, page: () => const MonitoringPage()),
  ];
}
