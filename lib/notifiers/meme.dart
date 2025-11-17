import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/entities/group.dart';
import 'package:meme_package/notifiers/group.dart';
import 'package:meme_package/notifiers/image.dart';
import 'package:meme_package/utils.dart';

class Meme extends ChangeNotifier {
  late List<GroupItem> _groups;
  List<GroupItem> get groups => _groups;

  set groups(List<GroupItem> e) {
    _groups = e;
    notifyListeners();
  }

  void addGroup({required String title}) {
    // _groups.add(Group.create(title: title));
    final g = GroupItem.create(title: title, sequence: _groups.length + 1);
    Config.db.groupDao
        .addGroup(GroupEntity(
      label: g.title,
      sequence: g.sequence,
    ))
        .then((value) {
      g.gid = value;
      _groups.add(g);
      notifyListeners();
    });
  }

  void removeGroup(GroupItem group) {
    Config.db.groupDao
        .removeGroup(GroupEntity(
      gid: group.gid,
      label: group.title,
      sequence: group.sequence,
    ))
        .then((value) {
      if (_groups.remove(group)) {
        // _groups.removeWhere((e) => e.gid == group.gid);
        for (var e in _groups) {
          if (e.sequence > group.sequence) {
            e.sequence--;
          }
        }
        print(_groups);
        notifyListeners();
      } else {
        Utils.logger.w('删除组失败');
      }
    });
  }

  Future<int> removeImage(ImageItem item) {
    return Config.db.imageDao.removeImage(item.imageEntity);
  }

  Future<void> updateItem({
    required int gid,
    required String hash,
    required File file,
  }) async {
    final g = _groups.firstWhere((e) => e.gid == gid);
    final item = g.items.firstWhere((e) => e.hash == hash);
    await item.update(newFile: file);
    Config.db.imageDao.updateImage(item.imageEntity);
    // notifyListeners();
  }

  Meme([List<GroupEntity>? g]) {
    groups = (g ?? [])
        .map((e) => GroupItem(
              gid: e.gid!,
              label: e.label,
              sequence: e.sequence,
            ))
        .toList();
  }

  ImageItem? findByHash(String hash) {
    for (var i = 0; i < _groups.length; i++) {
      final group = _groups[i];
      try {
        final item = group.items.firstWhere((item) => item.hash == hash);
        return item;
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  List<ImageItem> findByString(String str) {
    return _groups.map((group) => group.items).expand((e) => e).where((e) => e.content.contains(str) || e.filename.contains(str)).toList();
  }

  void updateItemsSrc() {
    for (var group in _groups) {
      for (var item in group.items) {
        item.refreshFile();
      }
    }
  }

  @override
  String toString() {
    return jsonEncode({
      'groups': groups,
    });
  }

  Map toJson() {
    return {
      'groups': groups,
    };
  }
}
