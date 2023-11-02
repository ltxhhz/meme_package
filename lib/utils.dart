import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'config.dart';
import 'utils/log_output.dart';

class Utils {
  static late Directory supportDir;
  static init() async {
    supportDir = await getApplicationSupportDirectory();
    supportDir.createSync(recursive: true);
  }

  static Logger? _logger;
  static Logger? _logger1;

  static Logger get logger {
    return Config.keepLog
        ? _logger1 ??= Logger(
            printer: PrettyPrinter(),
            filter: ProductionFilter(),
            output: CustomLogOutput(),
          )
        : _logger ??= Logger(
            printer: PrettyPrinter(),
            filter: Config.isDebug ? ProductionFilter() : null,
          );
  }
}
