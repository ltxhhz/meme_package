import 'package:floor/floor.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue * 1000);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch ~/ 1000;
  }
}
