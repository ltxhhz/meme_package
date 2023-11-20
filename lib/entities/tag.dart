import 'package:floor/floor.dart';
import './image.dart';

@Entity(
  tableName: 'tags',
  indices: [
    Index(
      value: [
        'name'
      ],
    )
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: [
        'iid'
      ],
      parentColumns: [
        'iid'
      ],
      entity: ImageItem,
    )
  ],
)
class Tag {
  @PrimaryKey(autoGenerate: true)
  final int? tid;

  final String name;

  final int iid;

  Tag({
    this.tid,
    required this.iid,
    required this.name,
  });
}
