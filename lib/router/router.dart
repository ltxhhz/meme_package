import 'package:flutter/material.dart';
import 'package:meme_package/router/routes/image_detail.dart';
import 'package:meme_package/router/routes/setting.dart';
import 'package:meme_package/utils.dart';

import 'routes/home.dart';
import 'routes/converter.dart';
import 'routes/test.dart';
import 'routes/tags.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  Utils.logger.d('route to: ${settings.name}');
  switch (settings.name) {
    case HomeRoute.name:
      return HomeRoute.getRoute();
    case ConverterRoute.name:
      return ConverterRoute.getRoute(args as ConverterRouteArg?);
    case ImageDetailRoute.name:
      return ImageDetailRoute.getRoute(args as ImageDetailRouteArg);
    case TestRoute.name:
      return TestRoute.getRoute();
    case SettingRoute.name:
      return SettingRoute.getRoute();
    case TagsRoute.name:
      return TagsRoute.getRoute();
    default:
      return HomeRoute.getRoute();
  }
}