import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:path/path.dart' as path;

import '../config.dart';
import '../utils.dart';

const List<FileFormat> fmts = [
  // Formats.fileUri,
  Formats.svg,
  Formats.gif,
  Formats.jpeg,
  Formats.png,
  Formats.webp,
];

class MyDropRegionWidget extends StatefulWidget {
  final Widget child;
  final void Function(List<File> files) onReceive;
  final String tipText;
  final bool makeTemp;
  final double strokeWidth;
  final double? fontSize;
  final BorderRadius? borderRadius;
  const MyDropRegionWidget({super.key, required this.onReceive, required this.child, this.tipText = '拖动到此', this.makeTemp = true, this.strokeWidth = 1, this.fontSize, this.borderRadius});

  @override
  State<MyDropRegionWidget> createState() => _MyDropRegionWidgetState();
}

class _MyDropRegionWidgetState extends State<MyDropRegionWidget> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onPerformDrop: (event) async {
        final List<File> files = [];
        final List<Future<void>> futures = [];
        for (var e in event.session.items) {
          for (var fmt in fmts) {
            if (e.canProvide(fmt)) {
              final com = Completer();
              futures.add(com.future);
              if (widget.makeTemp) {
                final su = await e.dataReader!.getSuggestedName();
                e.dataReader?.getFile(fmt, (value) async {
                  String? filename = value.fileName ?? su;
                  final fileData = await value.readAll();
                  filename ??= md5.convert(fileData).toString();
                  File file = File(path.join(Config.tempDir.path, filename));
                  if (file.existsSync()) {
                    try {
                      file.deleteSync();
                    } catch (e) {
                      final mime = lookupMimeType(filename, headerBytes: fileData.sublist(0, 20));
                      file = File(path.join(Config.tempDir.path, '${Utils.uuid}.${mime == null ? '' : extensionFromMime(mime)}'));
                    }
                  }
                  file.writeAsBytesSync(fileData);
                  files.add(file);
                  com.complete();
                });
              } else {
                e.dataReader?.getValue(Formats.fileUri, (value) {
                  files.add(File(value!.toFilePath()));
                  com.complete();
                });
              }
              break;
            }
          }
        }
        Future.wait(futures).then((value) {
          widget.onReceive(files);
        });
      },
      formats: fmts,
      onDropOver: (event) {
        if (event.session.items.indexWhere((e) => e.localData != null && (e.localData as Map)['type'] == 'image') == -1 && event.session.items.indexWhere((e) => fmts.indexWhere((e1) => e.canProvide(e1)) != -1) != -1) {
          setState(() {
            _isDragOver = true;
          });
          return DropOperation.copy;
        }
        setState(() {
          _isDragOver = false;
        });
        // if (event.session.allowedOperations.contains(DropOperation.copy)) {
        //   return DropOperation.copy;
        // } else {
        return DropOperation.none;
        // }
      },
      onDropLeave: _onDropLeave,
      // onDropEnded: (p0) {
      //   Utils.logger.i('ended');
      //   setState(() {
      //     _isDragOver = false;
      //   });
      // },
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _isDragOver ? 0.85 : 0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    color: Colors.grey,
                  ),
                  child: DottedBorder(
                    options: RectDottedBorderOptions(
                      strokeWidth: widget.strokeWidth,
                      dashPattern: const [
                        8,
                        4
                      ],
                      color: Colors.white,
                      // borderType: BorderType.RRect,
                      // radius: const Radius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        widget.tipText,
                        style: TextStyle(fontSize: widget.fontSize),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onDropLeave(DropEvent event) {
    setState(() {
      _isDragOver = false;
    });
  }
}

DragItemWidget dragItemWidget(
  BuildContext context, {
  required Widget child,
  required File file,
}) {
  return DragItemWidget(
    child: DraggableWidget(
      child: child,
    ),
    dragItemProvider: (p0) {
      final item = DragItem(localData: {
        'type': 'image',
      });
      getImgFormats(file).forEach(item.add);
      return item;
    },
    allowedOperations: () => [
      DropOperation.copy
    ],
    // liftBuilder: (context, child) {
    //   return Container(color: Colors.blue, child: child);
    // },
    // dragBuilder: (context, child) {
    //   return Container(color: Colors.red, child: child);
    // },
  );
}
