import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

import '../config.dart';

class Item {
  late File file;
  late String hash;
  String groupUuid;
  String filename;
  Item({
    String? hash,
    required this.groupUuid,
    required this.filename,
  }) {
    file = File(join(Config.dataPath.path, groupUuid, filename));
    if (hash != null) {
      this.hash = hash;
    }
  }

  Future<void> calcMD5() async {
    hash = md5.convert(file.readAsBytesSync()).toString();
  }

  @override
  String toString() {
    return jsonEncode({
      'path': file.path,
      'hash': hash,
    });
  }

  Map toJson() {
    return {
      'path': relative(file.path, from: Config.dataPath.path),
      'hash': hash,
    };
  }
}
