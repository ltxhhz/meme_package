import 'package:floor/floor.dart';

@Entity(tableName: 'tags')
class Tag {
  @PrimaryKey()
  final int tid;

  final String name;

  Tag(this.tid, this.name);
}
