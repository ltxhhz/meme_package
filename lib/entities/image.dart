import 'package:floor/floor.dart';
import 'package:meme_package/entities/group.dart';

@Entity(
  tableName: 'images',
  indices: [
    Index(
      value: [
        'hash'
      ],
      unique: true,
    )
  ],
  foreignKeys: [
    ForeignKey(childColumns: [
      'gid'
    ], parentColumns: [
      'gid'
    ], entity: Groups)
  ],
)
class ImageItem {
  @PrimaryKey(autoGenerate: true)
  final int? iid;
  final String hash;

  final String filename;

  late final int gid;

  ImageItem({
    this.iid,
    required this.hash,
    required this.filename,
    required this.gid,
  });
}
