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
  File? sourceFile;
  String? guuid;
  String? hash;
  ConverterRouteArg({
    this.internal = false,
    this.sourceFile,
    this.guuid,
    this.hash,
  });
}
