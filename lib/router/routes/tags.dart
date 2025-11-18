import 'package:flutter/material.dart';

import '../../pages/tags.dart';

class TagsRoute {
  static const name = '/tags';
  static Route getRoute() => MaterialPageRoute(
        builder: (context) => const TagsPage(),
      );
}