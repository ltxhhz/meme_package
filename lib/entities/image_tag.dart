import 'package:floor/floor.dart';

import './image.dart';
import './tag.dart';

@Entity(
  tableName: 'image_tags',
  foreignKeys: [
    ForeignKey(
      childColumns: [
        'image_id'
      ],
      parentColumns: [
        'iid'
      ],
      entity: ImageEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: [
        'tag_id'
      ],
      parentColumns: [
        'tid'
      ],
      entity: TagEntity,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
  indices: [
    Index(
      value: [
        'image_id',
        'tag_id'
      ],
      unique: true,
    )
  ],
)
class ImageTagEntity {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'image_id')
  final int imageId;
  @ColumnInfo(name: 'tag_id')
  final int tagId;

  ImageTagEntity({
    this.id,
    required this.imageId,
    required this.tagId,
  });
}
