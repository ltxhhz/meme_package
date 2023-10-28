import 'dart:async';

import 'package:context_menus/context_menus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/entities/group.dart';
import 'package:meme_package/entities/item.dart';
import 'package:meme_package/entities/meme.dart';
import 'package:meme_package/utils/platform_utils.dart';
import 'package:mime/mime.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:super_clipboard/super_clipboard.dart';

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
                tabAlignment: TabAlignment.startOffset,
                tabs: context
                    .watch<Meme>()
                    .groups
                    .map(
                      (e) => Tab(
                        child: ContextMenuRegion(
                          contextMenu: GenericContextMenu(
                            buttonConfigs: [
                              ContextMenuButtonConfig(
                                '新建',
                                onPressed: () {
                                  _showAddDialog();
                                },
                              ),
                              ContextMenuButtonConfig(
                                '删除',
                                onPressed: () {
                                  print('删除组');
                                },
                              ),
                            ],
                          ),
                          child: Text(e.title),
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
              Config.save();
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
                          return ContextMenuRegion(
                            enableLongPress: PlatformUtils.isMobile,
                            contextMenu: GenericContextMenu(
                              buttonConfigs: [
                                if (PlatformUtils.isNotMobile)
                                  ContextMenuButtonConfig(
                                    '复制',
                                    onPressed: () async {
                                      final item = DataWriterItem();
                                      item.add(Formats.fileUri(value[index].file.uri));
                                      item.add(Formats.htmlText("<img src=\"file://${value[index].file.uri.path}\" />"));
                                      switch (lookupMimeType(value[index].file.path)) {
                                        case 'image/png':
                                          item.add(Formats.png(value[index].file.readAsBytesSync()));
                                          break;
                                        case 'image/jpeg':
                                          item.add(Formats.jpeg(value[index].file.readAsBytesSync()));
                                          break;
                                        case 'image/webp':
                                          item.add(Formats.webp(value[index].file.readAsBytesSync()));
                                          break;
                                        case 'image/bmp':
                                          item.add(Formats.bmp(value[index].file.readAsBytesSync()));
                                          break;
                                        case 'image/gif':
                                          item.add(Formats.gif(value[index].file.readAsBytesSync()));
                                          break;
                                        case 'image/svg+xml':
                                          item.add(Formats.svg(value[index].file.readAsBytesSync()));
                                          break;
                                        default:
                                        // item.add(Formats.fileUri(value[index].path.uri));
                                      }
                                      ClipboardWriter.instance.write([
                                        item
                                      ]).then((value) {
                                        showToast('已复制');
                                      });
                                    },
                                  ),
                                ContextMenuButtonConfig(
                                  '添加',
                                  onPressed: () {
                                    _showAddDialog();
                                  },
                                ),
                                ContextMenuButtonConfig(
                                  '设置关键字',
                                  onPressed: () {
                                    _showAddDialog();
                                  },
                                ),
                                ContextMenuButtonConfig(
                                  '删除',
                                  onPressed: () {
                                    _showAddDialog();
                                  },
                                ),
                              ],
                            ),
                            child: InkWell(
                              child: value[index].shortcut.isEmpty
                                  ? Image.file(value[index].file)
                                  : Tooltip(
                                      message: value[index].shortcut,
                                      child: Image.file(value[index].file),
                                    ),
                              onTap: () {
                                print('tap');
                              },
                            ),
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
          Config.save();
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
