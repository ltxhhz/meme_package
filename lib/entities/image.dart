import 'package:floor/floor.dart';
import './group.dart';

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
    ForeignKey(
      childColumns: [
        'gid'
      ],
      parentColumns: [
        'gid'
      ],
      entity: Groups,
    )
  ],
)
class ImageItem {
  @PrimaryKey(autoGenerate: true)
  final int? iid;
  final String hash;

  final String filename;

  final int gid;

  final DateTime time;

  final int sequence;

  final String mime;

  final String content;

  ImageItem({
    this.iid,
    required this.hash,
    required this.filename,
    required this.gid,
    required this.time,
    required this.sequence,
    required this.mime,
    this.content = '',
  });
}
