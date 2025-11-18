import 'package:flutter/material.dart';
import 'package:meme_package/entities/tag.dart';
import 'package:super_context_menu/super_context_menu.dart';

Widget tagItem(
  BuildContext context,
  TagEntity tag, {
  List<MenuElement>? menuItems,
  void Function(TagEntity tag)? onTap,
}) {
  return ContextMenuWidget(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor.withAlpha(85)),
        ),
        child: Text(
          tag.name,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14,
          ),
        ),
      ),
      onTap: () {
        onTap?.call(tag);
      },
    ),
    menuProvider: (menuRequest) {
      return menuItems == null ? null : Menu(children: menuItems);
    },
  );
}
