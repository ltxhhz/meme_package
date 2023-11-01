import 'dart:convert';
import 'dart:io';

import 'package:floor/floor.dart';
import 'package:meme_package/db/app_db.dart';
import 'package:meme_package/notifiers/meme.dart';
import 'package:path/path.dart' as path;
import 'package:meme_package/utils.dart';

class Config {
  static late Directory dataPath;
  static late File memeDBFile;
  static late Meme meme;
  static late AppDatabase db;
  static init() async {
    dataPath = Directory(path.join(Utils.supportDir.path, 'data'));
    dataPath.createSync();
    memeDBFile = File(path.join(Utils.supportDir.path, 'meme.db'));
    db = await $FloorAppDatabase.databaseBuilder(memeDBFile.path).addCallback(_dbCallback).build();

    if (!memeDBFile.existsSync()) {
      meme = Meme();
    } else {
      meme = Meme(await db.groupDao.getAllGroups());
      if (meme.groups.isNotEmpty) {
        meme.groups.forEach((group) {
          group.getOwnImages();
        });
      }
    }
  }

  static final _dbCallback = Callback(
    onCreate: (database, version) {
      print('on create');
      database.execute('''CREATE TRIGGER update_sequence
        AFTER DELETE ON groups
        FOR EACH ROW
        BEGIN
            UPDATE groups
            SET sequence = sequence - 1
            WHERE sequence > OLD.sequence;
        END;''');
    },
  );
}
