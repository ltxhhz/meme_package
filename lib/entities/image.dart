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
      entity: GroupEntity,
    )
  ],
)
class ImageEntity {
  @PrimaryKey(autoGenerate: true)
  int? iid;
  final String hash;

  final String filename;

  final int gid;

  final DateTime time;

  final int sequence;

  final String mime;

  final String content;

  ImageEntity({
    this.iid,
    required this.hash,
    required this.filename,
    required this.gid,
    required this.time,
    required this.sequence,
    required this.mime,
    this.content = '',
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImageEntity && runtimeType == other.runtimeType && iid == other.iid && hash == other.hash && gid == other.gid && filename == other.filename && sequence == other.sequence && mime == other.mime && content == other.content;

  @override
  int get hashCode => iid.hashCode ^ hash.hashCode ^ gid.hashCode ^ time.hashCode ^ mime.hashCode;

  @override
  String toString() {
    return 'Task{iid: $iid, hash: $hash, time: ${time.millisecondsSinceEpoch}, sequence: $sequence, mime: $mime, content: $content}';
  }
}
