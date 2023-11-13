import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:meme_package/entities/image.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../config.dart';

class Item {
  late File file;
  late String hash;
  late int iid;
  int gid;
  String groupUuid;
  String filename;
  late DateTime time;
  int sequence;
  late String mime;

  ImageItem get imageEntity => ImageItem(
        iid: iid,
        hash: hash,
        filename: filename,
        gid: gid,
        time: time,
        sequence: sequence,
        mime: mime,
      );

  Item({
    String? hash,
    required this.groupUuid,
    required this.gid,
    required this.filename,
    DateTime? time,
    required this.sequence,
    int? iid,
    String? mime,
  }) {
    file = File(join(Config.dataPath.path, groupUuid, filename));
    if (hash != null) {
      this.hash = hash;
    }
    this.time = time ?? DateTime.now();
    if (mime != null && mime.isNotEmpty) {
      this.mime = mime;
    } else {
      this.mime = mime ?? lookupMimeType(file.path) ?? '';
    }
    if (iid != null) {
      this.iid = iid;
    }
  }

  Future<void> update({
    required File newFile,
  }) async {
    file.deleteSync();
    file = File(join(file.parent.path, filename = basename(newFile.path)));
    newFile.copySync(file.path);
    mime = lookupMimeType(file.path) ?? '';
    newFile.deleteSync();
    await calcMD5();
    time = DateTime.now();
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
