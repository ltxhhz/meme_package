import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:meme_package/entities/item.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';

class Group extends ChangeNotifier {
  late String dirName;
  late String _title;
  String get title => _title;

  set title(String e) {
    _title = e;
    notifyListeners();
  }

  List<Item> _items = [];
  List<Item> get items => _items;

  set items(List<Item> e) {
    _items = e;
    notifyListeners();
  }

  Group(Map<String, dynamic> map) {
    dirName = map['dirName'] ?? Uuid().v4();
    title = map['title']!;
    items = (map['items'] as List).map((e) => Item(e)).toList();
  }

  Group.create({required String title}) {
    this.title = title;
    dirName = Uuid().v4();
  }

  Future<void> addImages(List<XFile> imgs) async {
    for (var img in imgs) {
      final imgSavePath = join(Config.dataPath.path, dirName, img.name);
      Directory(imgSavePath).parent.createSync(recursive: true);
      await img.saveTo(imgSavePath);
      final item = Item.create(file: File(imgSavePath));
      await item.calcMD5();
      _items.add(item);
    }
    notifyListeners();
  }

  @override
  String toString() {
    return jsonEncode({
      'title': title,
      'items': _items,
    });
  }

  Map toJson() {
    return {
      'title': title,
      'items': _items,
    };
  }
}
