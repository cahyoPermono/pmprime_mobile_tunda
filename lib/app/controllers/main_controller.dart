import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/engine/engine_status_page.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/spk/spk_list_page.dart';
import 'package:vasa_mobile_tunda_flutter/app/ui/pages/monitoring/monitoring_page.dart';

class MainController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<Widget> pages = [
    const EngineStatusPage(),
    const SpkListPage(),
    const MonitoringPage(),
  ];

  void changePage(int index) {
    selectedIndex.value = index;
  }
}
