import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meme_package/entities/image.dart';
import 'package:meme_package/notifiers/image.dart';
import 'package:path/path.dart';

import '../config.dart';
import '../utils.dart';

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
    this.uuid = uuid ?? Utils.uuid;
    title = label;
  }

  Group.create({
    required String title,
    required this.sequence,
  }) {
    this.title = title;
    uuid = Utils.uuid;
  }

  Future<void> getOwnImages() async {
    final imgs = await Config.db.groupDao.getAllImages(gid);
    _items.addAll(imgs.map((e) => Item(
          groupUuid: uuid,
          hash: e.hash,
          gid: gid,
          filename: e.filename,
          sequence: e.sequence,
          iid: e.iid,
          mime: e.mime,
        )));
    notifyListeners();
  }

  Item getImageById(int id) {
    return _items.firstWhere((img) => img.iid == id);
  }

  Future<void> addImages(List<File> imgs) async {
    final List<ImageItem> imgItems = [];
    final List<Function> cb = [];
    int seq = await Config.db.imageDao.getMaxSequence() ?? 0;
    for (var img in imgs) {
      final imgSavePath = join(Config.dataPath.path, uuid, basename(img.path));
      Directory(imgSavePath).parent.createSync(recursive: true);
      img.copySync(imgSavePath);
      img.deleteSync();
      final item = Item(groupUuid: uuid, gid: gid, filename: basename(img.path), sequence: ++seq);
      await item.calcMD5();
      _items.add(item);
      cb.add((int iid) {
        item.iid = iid;
      });
      imgItems.add(ImageItem(
        hash: item.hash,
        filename: basename(item.file.path),
        gid: gid,
        time: item.time,
        sequence: seq,
        mime: item.mime,
      ));
    }
    //todo 判断是否MD5已存在
    await Config.db.imageDao.addImages(imgItems).then((value) {
      for (var i = 0; i < value.length; i++) {
        cb[i](value[i]);
      }
    });
    notifyListeners();
  }

  Future<void> removeImage(Item item) {
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
