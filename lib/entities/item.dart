import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

import '../config.dart';

class Item {
  late File file;
  String shortcut = '';
  late String hash;
  Item(Map<String, dynamic> map) {
    file = File(join(Config.dataPath.path, map['path']));
    shortcut = map['shortcut'] ?? '';
    hash = map['hash']!;
  }

  Item.create({required this.file});

  Future<void> calcMD5() async {
    hash = md5.convert(file.readAsBytesSync()).toString();
  }

  @override
  String toString() {
    return jsonEncode({
      'path': file.path,
      'hash': hash,
      'shortcut': shortcut,
    });
  }

  Map toJson() {
    return {
      'path': relative(file.path, from: Config.dataPath.path),
      'hash': hash,
      'shortcut': shortcut,
    };
  }
}
