import 'package:flutter/material.dart';
import 'package:meme_package/pages/setting.dart';

class SettingRoute {
  static const name = '/setting';
  static Route getRoute() => MaterialPageRoute(
        builder: (context) => const SettingPage(),
      );
}
