import 'package:flutter/material.dart';

import '../../pages/home.dart';

class HomeRoute {
  static const name = '/home';
  static Route getRoute() => MaterialPageRoute(
        builder: (context) => const Home(),
      );
}
