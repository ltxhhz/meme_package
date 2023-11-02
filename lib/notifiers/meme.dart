import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/entities/group.dart';
import 'package:meme_package/notifiers/group.dart';

class Meme extends ChangeNotifier {
  late List<Group> _groups;
  List<Group> get groups => _groups;

  set groups(List<Group> e) {
    _groups = e;
    notifyListeners();
  }

  void addGroup({required String title}) {
    // _groups.add(Group.create(title: title));
    Config.db.groupDao.getMaxSequence().then((value) {
      final g = Group.create(title: title, sequence: (value ?? 0) + 1);
      Config.db.groupDao
          .addGroup(Groups(
        label: g.title,
        sequence: g.sequence,
        uuid: g.uuid,
      ))
          .then((value) {
        g.gid = value;
        _groups.add(g);
        notifyListeners();
      });
    });
  }

  void removeGroup(Group group) {
    Config.db.groupDao
        .removeGroup(Groups(
      gid: group.gid,
      label: group.title,
      sequence: group.sequence,
      uuid: group.uuid,
    ))
        .then((value) {
      _groups.removeWhere((e) => e.gid == group.gid);
      _groups.forEach((e) {
        if (e.sequence > group.sequence) {
          e.sequence--;
        }
      });
      print(_groups);
      notifyListeners();
    });
  }

  Meme([List<Groups>? g]) {
    groups = (g ?? [])
        .map((e) => Group(
              gid: e.gid!,
              label: e.label,
              sequence: e.sequence,
              uuid: e.uuid,
            ))
        .toList();
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
