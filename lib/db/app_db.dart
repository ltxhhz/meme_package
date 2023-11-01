import 'dart:async';
import 'package:floor/floor.dart';
import 'package:meme_package/dao/group_dao.dart';
import 'package:meme_package/dao/image_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:meme_package/entities/group.dart';
import 'package:meme_package/entities/image.dart';

part 'app_db.g.dart';

@Database(version: 1, entities: [
  Groups,
  ImageItem,
])
abstract class AppDatabase extends FloorDatabase {
  GroupDao get groupDao;
  ImageDao get imageDao;
}
