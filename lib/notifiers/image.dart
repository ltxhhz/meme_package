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
  late DateTime time;
  int sequence;

  Item({
    String? hash,
    required this.groupUuid,
    required this.filename,
    DateTime? time,
    required this.sequence,
  }) {
    file = File(join(Config.dataPath.path, groupUuid, filename));
    if (hash != null) {
      this.hash = hash;
    }
    this.time = time ?? DateTime.now();
  }

  Future<void> calcMD5() async {
    hash = md5.convert(file.readAsBytesSync()).toString();
  }

  @override
  String toString() {
    return jsonEncode({
      'path': file.path,
      'hash': hash,
      'uuid': groupUuid,
      'filename': filename,
    });
  }

  Map toJson() {
    return {
      'path': file.path,
      'hash': hash,
      'uuid': groupUuid,
      'filename': filename,
    };
  }
}
