import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import 'config.dart';
import 'utils/log_output.dart';

class Utils {
  static init() async {}

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

  static String get uuid => const Uuid().v4().replaceAll('-', '');

  static bool isWebpDynamic(File webpFile) {
    var vp8x = webpFile.readAsBytesSync().sublist(12, 16);
    return vp8x[0] == 0x56 && vp8x[1] == 0x50 && vp8x[2] == 0x38 && vp8x[3] == 0x58;
  }

  /// 递归移动文件夹
  /// [sourceDirectory] 源文件夹
  /// [targetDirectory] 目标文件夹
  ///
  static Future<void> moveFolder(Directory sourceDirectory, Directory targetDirectory) async {
    targetDirectory.createSync(recursive: true);
    for (var entity in sourceDirectory.listSync()) {
      logger.d('move entity: ${entity.path}');
      if (entity is File) {
        final targetFile = File(path.join(targetDirectory.path, entity.uri.pathSegments.last));
        entity.copySync(targetFile.path);
      } else if (entity is Directory) {
        await moveFolder(entity, Directory(path.join(targetDirectory.path, entity.uri.pathSegments.lastWhere((e) => e.isNotEmpty))));
      } else {
        logger.w('${entity.path} is not a file or directory');
      }
    }
  }
}

List<FutureOr<EncodedData>> getImgFormats(File file) {
  final List<FutureOr<EncodedData>> items = [];
  items.add(Formats.fileUri(file.uri));
  switch (lookupMimeType(file.path)) {
    case 'image/png':
      items.add(Formats.htmlText("<img src=\"file://${file.uri.path}\" />"));
      items.add(Formats.png(file.readAsBytesSync()));
      break;
    case 'image/jpeg':
      items.add(Formats.htmlText("<img src=\"file://${file.uri.path}\" />"));
      items.add(Formats.jpeg(file.readAsBytesSync()));
      break;
    case 'image/webp':
      final fileData = file.readAsBytesSync();
      items.add(Formats.htmlText("<img src=\"file://${file.uri.path}\" />"));
      items.add(Formats.webp(fileData));
      // if (Utils.isWebpDynamic(file)) {
      //   Utils.logger.i('dynamic webp');
      //   final ff = File(path.join(Config.tempDir.path, '${path.basenameWithoutExtension(file.path)}.gif'));
      //   final webp = img.decodeWebP(fileData)!;
      //   Utils.logger.i(webp.frames.length);
      //   // ff.writeAsBytesSync(img.encodeGif(webp));
      //   // items.add(Formats.gif(ff.readAsBytesSync()));
      //   // items.add(Formats.htmlText("<img src=\"file://${file.uri.path}.gif\" />"));
      // } else {
      //   Utils.logger.i('static webp');
      //   final webp = img.decodeWebP(fileData)!;
      //   Utils.logger.i(webp.frames.length);
      //   // items.add(Formats.png(img.encodePng(img.decodeWebP(fileData)!)));
      //   // items.add(Formats.htmlText("<img src=\"file://${file.uri.path}.png\" />"));
      // }
      break;
    case 'image/bmp':
      items.add(Formats.htmlText("<img src=\"file://${file.uri.path}\" />"));
      items.add(Formats.bmp(file.readAsBytesSync()));
      break;
    case 'image/gif':
      items.add(Formats.htmlText("<img src=\"file://${file.uri.path}\" />"));
      items.add(Formats.gif(file.readAsBytesSync()));
      break;
    case 'image/svg+xml':
      items.add(Formats.htmlText("<img src=\"file://${file.uri.path}\" />"));
      items.add(Formats.svg(file.readAsBytesSync()));
      break;
    default:
      items.add(Formats.plainText(file.path.replaceFirst(file.parent.path, '')));
  }
  return items;
}
