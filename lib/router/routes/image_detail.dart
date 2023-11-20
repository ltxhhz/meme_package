import 'package:flutter/material.dart';

import '../../pages/image_detail.dart';

class ImageDetailRoute {
  static const name = '/image-detail';
  static Route getRoute(ImageDetailRouteArg args) => MaterialPageRoute(
        builder: (context) => const ImageDetailPage(),
        settings: RouteSettings(arguments: args),
      );
}

class ImageDetailRouteArg {
  int imageId;
  int groupId;
  ImageDetailRouteArg({
    required this.imageId,
    required this.groupId,
  });
}
