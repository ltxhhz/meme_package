import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:meme_package/config.dart';
import 'package:mime/mime.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:image/image.dart' as img;

import '../utils.dart';

class ConverterTasks extends ChangeNotifier {
  final List<ConverterTask> tasks = [];
  File? _inputFile;
  File? get inputFile => _inputFile;

  ///赋值后自动配置获取mime
  set inputFile(File? e) {
    _inputFile = e!;
    final mime = lookupMimeType(e.path);
    if (mime != null) {
      if (mime == 'image/webp') {
        isWebpDynamic = Utils.isWebpDynamic(e);
      }
      _inputFormat = Formats.standardFormats.firstWhere((e) => e is SimpleFileFormat && e.mimeTypes![0] == mime) as SimpleFileFormat;
    } else {
      _inputFormat = null;
    }
    notifyListeners();
  }

  SimpleFileFormat? _inputFormat = Formats.png;
  SimpleFileFormat? get inputFormat => _inputFormat;

  set inputFormat(SimpleFileFormat? e) {
    _inputFormat = e;
    notifyListeners();
  }

  bool isWebpDynamic = false;

  SimpleFileFormat _targetFormat = Formats.png;
  SimpleFileFormat get targetFormat => _targetFormat;

  set targetFormat(SimpleFileFormat e) {
    _targetFormat = e;
    notifyListeners();
  }

  Future<void> push() {
    final newExt = extensionFromMime(targetFormat.mimeTypes![0]);
    final tempFile = File(path.join(Config.tempDir.createTempSync('meme-package').path, '${path.basenameWithoutExtension(inputFile!.path)}.${newExt == 'jpe' ? 'jpg' : newExt}'));
    final task = ConverterTask(
      sourceFormat: inputFormat!,
      source: inputFile!,
      targetFormat: targetFormat,
      target: tempFile,
    );
    tasks.add(task);
    notifyListeners();
    final formats0 = [
      Formats.webp,
      Formats.png,
      Formats.jpeg,
      Formats.gif
    ];
    final formats1 = [
      Formats.png,
      Formats.jpeg,
      Formats.gif
    ];
    return compute<Map<int, String>, bool>((message) async {
      final sourceFile = message[0]!;
      final targetFile = message[1]!;
      final sourceFormat = message[2]!;
      final targetFormat = message[3]!;
      try {
        img.Image image;
        switch (sourceFormat) {
          case '0':
            image = (await img.decodeWebPFile(sourceFile))!;
            break;
          case '1':
            image = (await img.decodePngFile(sourceFile))!;
            break;
          case '2':
            image = (await img.decodeJpgFile(sourceFile))!;
            break;
          case '3':
            image = (await img.decodeGifFile(sourceFile))!;
            break;
          default:
            image = (await img.decodeImageFile(sourceFile))!;
        }

        switch (targetFormat) {
          case '0':
            await img.encodePngFile(targetFile, image);
            break;
          case '1':
            await img.encodeJpgFile(targetFile, image);
            break;
          case '2':
            await img.encodeGifFile(targetFile, image);
            break;
          default:
        }
        return true;
      } catch (err) {
        return false;
      }
    }, {
      0: task.source.path,
      1: task.target.path,
      2: formats0.indexOf(task.sourceFormat).toString(),
      3: formats1.indexOf(task.targetFormat).toString()
    }).then((value) {
      Utils.logger.i(value);
      if (value) {
        task.rate = 1;
      } else {
        task.rate = -1;
      }
      notifyListeners();
    }).catchError((err) {
      Utils.logger.e(err);
    });
  }

  void clearTasks() {
    tasks.clear();
    notifyListeners();
  }
}

class ConverterTask {
  final SimpleFileFormat sourceFormat;
  final File source;
  final SimpleFileFormat targetFormat;
  final File target;
  double rate = 0;

  ConverterTask({
    required this.sourceFormat,
    required this.source,
    required this.targetFormat,
    required this.target,
  });
}
