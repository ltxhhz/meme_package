import 'package:floor/floor.dart';
import '../entities/tag.dart';
import '../entities/image.dart';

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

  // @Query("select * from tags where iid=:iid")
  // Future<List<TagEntity>> getTagByIid(int iid);

  @Query('''
  SELECT * FROM images 
  WHERE iid IN (
    SELECT image_id FROM image_tags 
    WHERE tag_id = :tagId
  )
''')
  Future<List<ImageEntity>> getImagesByTag(int tagId);

  @Query('''
  SELECT * FROM tags 
  WHERE tid IN (
    SELECT tag_id FROM image_tags 
    WHERE image_id = :imageId
  )
''')
  Future<List<TagEntity>> getTagsForImage(int imageId);

  @Query('SELECT * FROM tags')
  Future<List<TagEntity>> getAllTags();

  // 搜索tag
  @Query('''
  SELECT * FROM tags 
  WHERE name LIKE '%' || :name || '%'
''')
  Future<List<TagEntity>> searchTag(String name);
}
