import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Utils {
  static late Directory supportDir;
  static init() async {
    supportDir = await getApplicationSupportDirectory();
    supportDir.createSync(recursive: true);
  }
}
