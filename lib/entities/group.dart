import 'package:floor/floor.dart';

@Entity(tableName: 'groups')
class GroupEntity {
  @PrimaryKey(autoGenerate: true)
  int? gid;

  String label;

  int sequence;

  GroupEntity({
    this.gid,
    required this.label,
    required this.sequence,
  });
}
