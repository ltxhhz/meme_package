import 'package:floor/floor.dart';
import 'package:meme_package/entities/image.dart';

@dao
abstract class ImageDao {
  @insert
  Future<int> addImage(ImageEntity imageItem);

  @insert
  Future<List<int>> addImages(List<ImageEntity> imageItem);

  @update
  Future<int> updateImage(ImageEntity imageItem);

  // @Update(onConflict: OnConflictStrategy.replace)
  // Future updateTag(ImageItem imageItem);

  /// 根据content查询图片
  @Query('''
  SELECT * FROM images 
  WHERE content LIKE '%' || :content || '%'
  ''')
  Future<List<ImageEntity>> searchByContent(String content);

  // 查询所有图片
  @Query('SELECT * FROM images')
  Future<List<ImageEntity>> findAllImages();

  /// 删除图片
  @delete
  Future<int> removeImage(ImageEntity imageItem);

  @delete
  Future<int> removeImages(List<ImageEntity> list);
}
