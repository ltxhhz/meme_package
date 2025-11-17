import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meme_package/components/drop_region.dart';
import 'package:meme_package/notifiers/image.dart';
import 'package:provider/provider.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:tuple/tuple.dart';

ContextMenuWidget imageGrid(
  BuildContext context,
  ImageItem imageItem, {
  void Function()? onTap,
  List<MenuElement> menuElements = const [],
}) {
  return ContextMenuWidget(
    child: dragItemWidget(context,
        child: InkWell(
          onTap: onTap,
          child: Container(
            foregroundDecoration: RotatedCornerDecoration.withColor(
              color: Theme.of(context).primaryColor.withAlpha(180),
              badgeSize: Size.square(20.h),
              textSpan: TextSpan(
                text: imageItem.mime.replaceFirst('image/', ''),
              ),
            ),
            child: Selector<ImageItem, Tuple2<String, File>>(
              builder: (context, value, child) => value.item1.isEmpty
                  ? Image.file(value.item2)
                  : Tooltip(
                      message: value.item1,
                      child: Image.file(value.item2),
                    ),
              selector: (p0, p1) => Tuple2(p1.content, p1.file),
            ),
          ),
        ),
        file: imageItem.file),
    menuProvider: (request) => Menu(children: menuElements),
  );
}
