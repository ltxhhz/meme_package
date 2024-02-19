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
}
