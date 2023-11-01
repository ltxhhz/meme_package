import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:meme_package/entities/image.dart';
import 'package:meme_package/notifiers/item.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';

class Group extends ChangeNotifier {
  late String uuid;
  late int sequence;
  late String _title;
  String get title => _title;

  set title(String e) {
    _title = e;
    notifyListeners();
  }

  late int gid;
  List<Item> _items = [];
  List<Item> get items => _items;

  set items(List<Item> e) {
    _items = e;
    notifyListeners();
  }

  Group({
    required String label,
    required this.sequence,
    required this.gid,
    String? uuid,
  }) {
    this.uuid = uuid ?? Uuid().v4().replaceAll('-', '');
    title = label;
  }

  Group.create({
    required String title,
    required this.sequence,
  }) {
    this.title = title;
    uuid = Uuid().v4().replaceAll('-', '');
  }

  Future<void> getOwnImages() async {
    final imgs = await Config.db.groupDao.getAllImages(gid);

    _items.addAll(imgs.map((e) => Item(groupUuid: uuid, hash: e.hash, filename: e.filename)));
    notifyListeners();
  }

  Future<void> addImages(List<XFile> imgs) async {
    final List<ImageItem> imgItems = [];
    for (var img in imgs) {
      final imgSavePath = join(Config.dataPath.path, uuid, img.name);
      Directory(imgSavePath).parent.createSync(recursive: true);
      await img.saveTo(imgSavePath);
      final item = Item(groupUuid: uuid, filename: img.name);
      await item.calcMD5();
      _items.add(item);
      imgItems.add(ImageItem(
        hash: item.hash,
        filename: basename(item.file.path),
        gid: gid,
      ));
    }
    await Config.db.imageDao.addImages(imgItems);
    notifyListeners();
  }

  @override
  String toString() {
    return jsonEncode({
      'gid': gid,
      'uuid': uuid,
      'title': title,
      'items': _items,
      'sequence': sequence,
    });
  }

  Map toJson() {
    return {
      'gid': gid,
      'uuid': uuid,
      'title': title,
      'items': _items,
      'sequence': sequence,
    };
  }
}
