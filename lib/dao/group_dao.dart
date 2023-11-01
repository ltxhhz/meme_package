import 'package:floor/floor.dart';
import 'package:meme_package/entities/group.dart';
import 'package:meme_package/entities/image.dart';

@dao
abstract class GroupDao {
  @insert
  Future<int> addGroup(Groups group);

  @delete
  Future<int> removeImage(ImageItem imageItem);

  @delete
  Future<int> removeImages(List<ImageItem> imageItem);

  @delete
  Future<int> removeGroup(Groups group);

  @Query('SELECT * FROM "groups"')
  Future<List<Groups>> getAllGroups();

  @Query('SELECT * FROM images where gid=:gid')
  Future<List<ImageItem>> getAllImages(int gid);
}
