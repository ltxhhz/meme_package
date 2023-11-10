import 'dart:io';

import 'package:flutter/material.dart';

import '../../pages/converter.dart';

class ConverterRoute {
  static const name = '/converter';
  static Route getRoute(ConverterRouteArg? arg) => MaterialPageRoute(
        builder: (context) => const ConverterPage(),
        settings: RouteSettings(arguments: arg),
      );
}

class ConverterRouteArg {
  bool internal;
  File? source;
  ConverterRouteArg({
    this.internal = false,
    this.source,
  });
}
