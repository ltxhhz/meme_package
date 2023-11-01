import 'package:floor/floor.dart';

@Entity(tableName: 'groups')
class Groups {
  @PrimaryKey(autoGenerate: true)
  int? gid;

  String label;

  int sequence;

  String uuid;

  Groups({
    this.gid,
    required this.label,
    required this.sequence,
    required this.uuid,
  });
}
