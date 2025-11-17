import 'package:floor/floor.dart';

@Entity(
  tableName: 'tags',
  indices: [
    Index(
      value: [
        'name'
      ],
    )
  ],
  // foreignKeys: [
  // ForeignKey(
  //   childColumns: [
  //     'iid'
  //   ],
  //   parentColumns: [
  //     'iid'
  //   ],
  //   entity: ImageEntity,
  // )
  // ],
)
class TagEntity {
  @PrimaryKey(autoGenerate: true)
  final int? tid;

  final String name;

  // final int iid;

  TagEntity({
    this.tid,
    // required this.iid,
    required this.name,
  });
}
