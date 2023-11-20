import 'package:floor/floor.dart';
import '../entities/tag.dart';

@dao
abstract class TagDao {
  @insert
  Future<int> addTag(Tag tag);

  @delete
  Future<int> removeTag(Tag tag);

  @update
  Future<int> updateTag(Tag tag);

  @Query("select * from tags where tid=:tid")
  Future<List<Tag>> getTag(int tid);

  @Query("select * from tags where iid=:iid")
  Future<List<Tag>> getTagByIid(int iid);
}
