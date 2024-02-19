import 'package:floor/floor.dart';
import 'package:meme_package/entities/group.dart';
import 'package:meme_package/entities/image.dart';

@dao
abstract class GroupDao {
  @insert
  Future<int> addGroup(GroupEntity group);

  @delete
  Future<int> removeImage(ImageEntity imageItem);

  @delete
  Future<int> removeImages(List<ImageEntity> imageItem);

  @delete
  Future<int> removeGroup(GroupEntity group);

  @Query('SELECT * FROM "groups"')
  Future<List<GroupEntity>> getAllGroups();

  @Query('SELECT * FROM images where gid=:gid')
  Future<List<ImageEntity>> getAllImages(int gid);
}
