import 'dart:io';

import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:meme_package/db/app_db.dart';
import 'package:meme_package/notifiers/meme.dart';
import 'package:path/path.dart' as path;
import 'package:meme_package/utils.dart';

class Config {
  static late Directory dataPath;
  static late File memeDBFile;
  static late Meme meme;
  static late AppDatabase db;

  static bool keepLog = true;
  static const bool isDebug = kDebugMode;
  static final List<String> logs = [];

  static init() async {
    dataPath = Directory(path.join(Utils.supportDir.path, 'data'));
    dataPath.createSync();
    memeDBFile = File(path.join(Utils.supportDir.path, 'meme.db'));
    final migration1to2 = Migration(1, 2, (database) async {
      Utils.logger.i('migration 1 to 2');
    });
    db = await $FloorAppDatabase
        .databaseBuilder(memeDBFile.path)
        .addMigrations([
          migration1to2
        ])
        .addCallback(_dbCallback)
        .build();

    if (!memeDBFile.existsSync()) {
      meme = Meme();
    } else {
      meme = Meme(await db.groupDao.getAllGroups());
      if (meme.groups.isNotEmpty) {
        for (var group in meme.groups) {
          group.getOwnImages();
        }
      }
    }
  }

  static final _dbCallback = Callback(
    onCreate: (database, version) {
      Utils.logger.i('on create');
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
