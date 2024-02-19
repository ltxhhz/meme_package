import 'package:floor/floor.dart';
import '../entities/tag.dart';

@dao
abstract class TagDao {
  @insert
  Future<int> addTag(TagEntity tag);

  @delete
  Future<int> removeTag(TagEntity tag);

  @update
  Future<int> updateTag(TagEntity tag);

  @Query("select * from tags where tid=:tid")
  Future<List<TagEntity>> getTag(int tid);

  @Query("select * from tags where iid=:iid")
  Future<List<TagEntity>> getTagByIid(int iid);
}
