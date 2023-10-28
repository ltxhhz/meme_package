import 'dart:convert';
import 'dart:io';

import 'package:meme_package/entities/meme.dart';
import 'package:path/path.dart' as path;
import 'package:meme_package/utils.dart';

class Config {
  static late Directory dataPath;
  static late File memeConfig;
  static late Meme meme;
  static init() async {
    dataPath = Directory(path.join(Utils.supportDir.path, 'data'));
    dataPath.createSync();
    memeConfig = File(path.join(Utils.supportDir.path, 'data', 'meme.json'));
    if (!memeConfig.existsSync()) {
      memeConfig.writeAsStringSync('{}');
      meme = Meme.create();
    } else {
      meme = Meme(memeConfig.readAsStringSync());
    }
    meme.addListener(save);
  }

  static save() {
    print(meme.toString());
    memeConfig.writeAsStringSync(jsonEncode(meme));
  }
}
