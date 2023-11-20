import 'package:flutter/material.dart';
import 'package:meme_package/router/routes/image_detail.dart';

import 'routes/home.dart';
import 'routes/converter.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case HomeRoute.name:
      return HomeRoute.getRoute();
    case ConverterRoute.name:
      return ConverterRoute.getRoute(args as ConverterRouteArg?);
    case ImageDetailRoute.name:
      return ImageDetailRoute.getRoute(args as ImageDetailRouteArg);
    default:
      return HomeRoute.getRoute();
  }
}
