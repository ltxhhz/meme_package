import 'package:floor/floor.dart';
import 'package:meme_package/entities/image.dart';

@dao
abstract class ImageDao {
  @insert
  Future<int> addImage(ImageItem imageItem);

  @insert
  Future<List<int>> addImages(List<ImageItem> imageItem);

  @update
  Future<int> updateImage(ImageItem imageItem);

  // @Update(onConflict: OnConflictStrategy.replace)
  // Future updateTag(ImageItem imageItem);

  @Query('SELECT MAX(sequence) FROM images;')
  Future<int?> getMaxSequence();
}
