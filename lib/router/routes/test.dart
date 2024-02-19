import 'package:flutter/material.dart';

import '../../pages/test.dart';

class TestRoute {
  static const name = '/test';
  static Route getRoute() => MaterialPageRoute(
        builder: (context) => const TestPage(),
      );
}
