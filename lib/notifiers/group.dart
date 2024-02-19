import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meme_package/entities/image.dart';
import 'package:meme_package/notifiers/image.dart';
import 'package:path/path.dart';

import '../config.dart';
import '../utils.dart';

class GroupItem extends ChangeNotifier {
  late String uuid;
  late int sequence;
  late String _title;
  String get title => _title;

  set title(String e) {
    _title = e;
    notifyListeners();
  }

  late int gid;
  List<ImageItem> _items = [];
  List<ImageItem> get items => _items;

  set items(List<ImageItem> e) {
    _items = e;
    notifyListeners();
  }

  GroupItem({
    required String label,
    required this.sequence,
    required this.gid,
    String? uuid,
  }) {
    this.uuid = uuid ?? Utils.uuid;
    title = label;
  }

  GroupItem.create({
    required String title,
    required this.sequence,
  }) {
    this.title = title;
    uuid = Utils.uuid;
  }

  Future<void> getOwnImages() async {
    final imgs = await Config.db.groupDao.getAllImages(gid);
    _items.addAll(imgs.map((e) => ImageItem(
          groupUuid: uuid,
          hash: e.hash,
          gid: gid,
          filename: e.filename,
          sequence: e.sequence,
          iid: e.iid,
          mime: e.mime,
          time: e.time,
          content: e.content,
        )));
    notifyListeners();
  }

  ImageItem getImageById(int id) {
    return _items.firstWhere((img) => img.iid == id);
  }

  Future<List<ImageItem>> addImages(List<File> imgs) async {
    final List<ImageEntity> imgItems = [];
    final List<ImageItem> existItems = [];
    final List<Function> cb = [];
    int seq = _items.length;
    for (var img in imgs) {
      final imgSavePath = join(Config.dataPath.path, uuid, basename(img.path));
      Directory(imgSavePath).parent.createSync(recursive: true);
      img.copySync(imgSavePath);
      img.deleteSync();
      final item = ImageItem(groupUuid: uuid, gid: gid, filename: basename(img.path), sequence: ++seq);
      await item.calcMD5();
      final exi = Config.meme.findByHash(item.hash);
      if (exi != null) {
        existItems.add(item);
      } else {
        _items.add(item);
        cb.add((int iid) {
          item.iid = iid;
        });
        imgItems.add(ImageEntity(
          hash: item.hash,
          filename: basename(item.file.path),
          gid: gid,
          time: item.time,
          sequence: seq,
          mime: item.mime,
        ));
      }
    }
    await Config.db.imageDao.addImages(imgItems).then((value) {
      for (var i = 0; i < value.length; i++) {
        cb[i](value[i]);
      }
    });
    notifyListeners();
    return existItems;
  }

  Future<void> removeImage(ImageItem item) {
    return Config.db.groupDao.removeImage(item.imageEntity).then((value) {
      _items.remove(item);
      notifyListeners();
    });
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
