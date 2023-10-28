import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meme_package/entities/group.dart';

class Meme extends ChangeNotifier {
  late List<Group> _groups;
  List<Group> get groups => _groups;

  set groups(List<Group> e) {
    _groups = e;
    notifyListeners();
  }

  void addGroup({required String title}) {
    _groups.add(Group.create(title: title));
    notifyListeners();
  }

  Meme(String str) {
    Map map = jsonDecode(str);
    if (map['groups'] != null) {
      groups = (map['groups'] as List).map((e) => Group(e)).toList();
    } else {
      groups = [];
    }
  }

  Meme.create() {
    groups = [];
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
