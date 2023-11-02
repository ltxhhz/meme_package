import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/notifiers/group.dart';
import 'package:meme_package/notifiers/image.dart';
import 'package:meme_package/notifiers/meme.dart';
import 'package:meme_package/utils/platform_utils.dart';
import 'package:mime/mime.dart';
import 'package:ndialog/ndialog.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class TabPage extends StatefulWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Config.meme,
      builder: (context, child) {
        if (context.watch<Meme>().groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '空',
                  style: TextStyle(fontSize: 40),
                ),
                TextButton(
                  onPressed: () {
                    _showAddDialog();
                  },
                  child: const Text('创建新组'),
                )
              ],
            ),
          );
        } else {
          if (_tabController == null) {
            _tabController = TabController(length: context.read<Meme>().groups.length, vsync: this);
          } else if (_tabController!.length != context.read<Meme>().groups.length) {
            _tabController!.dispose();
            _tabController = TabController(length: context.read<Meme>().groups.length, vsync: this);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: context
                      .read<Meme>()
                      .groups
                      .map((e) => ChangeNotifierProvider.value(
                            value: e,
                            builder: (context, child) => _tabView(context),
                          ))
                      .toList(),
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: EdgeInsets.zero,
                tabs: context
                    .watch<Meme>()
                    .groups
                    .map(
                      (e) => Tab(
                        height: 40.h,
                        child: ContextMenuWidget(
                          child: Tooltip(
                            message: e.title,
                            child: SizedBox.square(
                              dimension: 40.h,
                              child: e.items.isNotEmpty
                                  ? Image.file(
                                      e.items[0].file,
                                      // height: 20.h,
                                    )
                                  : Icon(
                                      Icons.star,
                                      size: 20.sp,
                                      color: Colors.amber,
                                    ),
                            ),
                          ),
                          menuProvider: (request) {
                            return Menu(children: [
                              MenuAction(
                                title: '新建',
                                callback: () {
                                  _showAddDialog();
                                },
                              ),
                              MenuAction(
                                title: '删除',
                                callback: () {
                                  print('删除组');
                                  NAlertDialog(
                                    dialogStyle: DialogStyle(titleDivider: true),
                                    title: const Text("删除组"),
                                    content: const Text("确定删除后，其中的图片将移动到默认组"),
                                    actions: <Widget>[
                                      TextButton(child: const Text("同时删除图片"), onPressed: () => Navigator.pop(context)),
                                      TextButton(
                                          child: const Text("确定"),
                                          onPressed: () {
                                            Config.meme.removeGroup(e);
                                            Navigator.pop(context);
                                          }),
                                      TextButton(child: const Text("取消"), onPressed: () => Navigator.pop(context)),
                                    ],
                                  ).show(context);
                                },
                              ),
                            ]);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _tabView(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: DropTarget(
          onDragDone: (details) {
            context.read<Group>().addImages(details.files).then((value) {
              print('添加成功');
            });
          },
          child: Selector<Group, List<Item>>(
            builder: (context, value, child) {
              return value.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('空'),
                          TextButton(
                            onPressed: () {
                              _addImages();
                            },
                            child: Text('添加'),
                          )
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 100,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: value.length + 1,
                      itemBuilder: (context, index) {
                        if (index == value.length) {
                          return ElevatedButton(
                            onPressed: () {
                              _addImages();
                            },
                            child: Text('添加'),
                          );
                        } else {
                          return ContextMenuWidget(
                            child: DragItemWidget(
                              child: DraggableWidget(
                                child: InkWell(
                                  child: Image.file(value[index].file), //
                                  onTap: () {
                                    print('tap');
                                  },
                                ),
                              ),
                              dragItemProvider: (p0) {
                                final item = DragItem(localData: {});
                                _getImgFormats(value[index].file).forEach(item.add);
                                return item;
                              },
                              allowedOperations: () => [
                                DropOperation.copy
                              ],
                            ),
                            menuProvider: (request) {
                              return Menu(children: [
                                if (PlatformUtils.isNotMobile)
                                  MenuAction(
                                    title: '复制',
                                    callback: () async {
                                      final item = DataWriterItem();
                                      _getImgFormats(value[index].file).forEach(item.add);
                                      ClipboardWriter.instance.write([
                                        item
                                      ]).then((value) {
                                        showToast('已复制');
                                      });
                                    },
                                  ),
                                MenuAction(
                                  title: '添加',
                                  callback: () {
                                    _showAddDialog();
                                  },
                                ),
                                MenuAction(
                                  title: '设置关键字',
                                  callback: () {
                                    _showAddDialog();
                                  },
                                ),
                                MenuAction(
                                  title: '删除',
                                  callback: () {
                                    _showAddDialog();
                                  },
                                ),
                              ]);
                            },
                          );
                        }
                      },
                    );
            },
            selector: (p0, p1) => p1.items,
            shouldRebuild: (previous, next) => true,
          ),
        ),
      ),
    );
  }

  List<FutureOr<EncodedData>> _getImgFormats(File file) {
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
        items.add(Formats.htmlText("<img src=\"file://${file.uri.path}\" />"));
        items.add(Formats.webp(file.readAsBytesSync()));
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

  Future<void> _addImages() {
    Completer completer = Completer();
    openFiles(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'images',
          extensions: [
            'jpg',
            'jpeg',
            'png',
            'gif',
            // 'webp',
            // 'apng'
          ],
        ),
      ],
    ).then((value) {
      if (value.isNotEmpty) {
        Config.meme.groups[_tabController!.index].addImages(value).then((value) {
          completer.complete();
        });
      }
    });
    return completer.future;
  }

  Future<void> _showAddDialog() {
    Completer completer = Completer();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String groupName = '';
        return AlertDialog(
          title: const Text('创建新组'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '组名'),
                onChanged: (value) {
                  print(value);
                  groupName = value;
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                completer.complete();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Config.meme.addGroup(title: groupName);
                completer.complete();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    return completer.future;
  }
}
