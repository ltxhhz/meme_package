import 'dart:async';
import 'package:floor/floor.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart' as sqflite;

import '../converters/date.dart';
import '../dao/group_dao.dart';
import '../dao/image_dao.dart';
import '../dao/tag_dao.dart';
import '../entities/group.dart';
import '../entities/image.dart';
import '../entities/tag.dart';

part 'app_db.g.dart';

@TypeConverters([
  DateTimeConverter
])
@Database(version: 1, entities: [
  Groups,
  ImageItem,
  Tag,
])
abstract class AppDatabase extends FloorDatabase {
  GroupDao get groupDao;
  ImageDao get imageDao;
  TagDao get tagDao;
}
