import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meme_package/components/drop_region.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/notifiers/group.dart';
import 'package:meme_package/notifiers/image.dart';
import 'package:meme_package/notifiers/meme.dart';
import 'package:meme_package/router/routes/image_detail.dart';
import 'package:meme_package/utils/platform_utils.dart';
import 'package:ndialog/ndialog.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:super_hot_key/super_hot_key.dart';
import 'package:tuple/tuple.dart';

import '../router/routes/converter.dart';
import '../utils.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with TickerProviderStateMixin, RouteAware {
  TabController? _tabController;
  HotKey? _hotKey;
  AppLifecycleListener? _listener;

  @override
  void initState() {
    super.initState();
    _registerPasteHotKey();
    _listener = AppLifecycleListener(
      // onShow: () => Utils.logger.i('show'),
      onResume: () {
        // Utils.logger.i('resume');
        _hotKey?.dispose().then((value) {
          _registerPasteHotKey();
        });
      },
      // onHide: () => Utils.logger.i('hide'),
      onInactive: () {
        // Utils.logger.i('inactive');
        _hotKey?.dispose();
      },
      // onPause: () => Utils.logger.i('pause'),
      // onDetach: () => Utils.logger.i('detach'),
      // onRestart: () => Utils.logger.i('restart'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Config.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
    _hotKey?.dispose();
    _listener?.dispose();
    Config.routeObserver.unsubscribe(this);
  }

  @override
  void didPopNext() {
    // Utils.logger.i('did pop next');
    super.didPopNext();
    _registerPasteHotKey();
  }

  @override
  void didPushNext() {
    // Utils.logger.i('did push next');
    super.didPushNext();
    _hotKey?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Config.meme,
      builder: (context, child) {
        final groups = context.read<Meme>().groups;
        // if (groups.isEmpty) {
        //   return Center(
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         const Text(
        //           '空',
        //           style: TextStyle(fontSize: 40),
        //         ),
        //         TextButton(
        //           onPressed: () {
        //             _showAddDialog();
        //           },
        //           child: const Text('创建新组'),
        //         )
        //       ],
        //     ),
        //   );
        // } else {
        if (_tabController == null) {
          _tabController = TabController(length: groups.length, vsync: this);
        } else if (_tabController!.length != groups.length) {
          final i = _tabController!.index;
          _tabController!.dispose();
          _tabController = TabController(initialIndex: i, length: groups.length, vsync: this);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SizedBox.expand(
                child: TabBarView(
                  controller: _tabController,
                  children: context
                      .watch<Meme>()
                      .groups
                      .map((e) => ChangeNotifierProvider.value(
                            value: e,
                            builder: (context, child) => _tabView(context),
                          ))
                      .toList(),
                ),
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
                            if (e.gid != 1)
                              MenuAction(
                                title: '删除',
                                callback: () {
                                  print('删除组');
                                  bool deleteImages = false;
                                  NAlertDialog(
                                    dialogStyle: DialogStyle(titleDivider: true),
                                    title: const Text("删除组"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text("确定删除后，其中的图片将移动到默认组"),
                                        Row(children: [
                                          const Text("同时删除图片"),
                                          Checkbox(
                                            value: deleteImages,
                                            onChanged: (value) {
                                              deleteImages = value ?? false;
                                            },
                                          ),
                                        ]),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                          child: const Text("确定"),
                                          onPressed: () {
                                            //todo 删除组内图片
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
        // }
      },
    );
  }

  Widget _tabView(BuildContext context) {
    final group = context.read<GroupItem>();
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: MyDropRegionWidget(
          strokeWidth: 5,
          fontSize: 30.sp,
          borderRadius: BorderRadius.circular(15),
          onReceive: (files) {
            group.addImages(files).then((value) {
              if (value.isNotEmpty) {
                showToast('${value.length}个图片已存在');
              }
              print('添加成功');
            });
          },
          child: Selector<GroupItem, List<ImageItem>>(
            builder: (context, value, child) {
              return value.isEmpty
                  ? Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('拖动图片到此 或'),
                        TextButton(
                          onPressed: () {
                            _addImages().then((value) {
                              if (value.isNotEmpty) {
                                showToast('${value.length}个图片已存在');
                              }
                              print('添加成功');
                            });
                          },
                          child: const Text('添加'),
                        )
                      ],
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 100,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: value.length + 1,
                      itemBuilder: (context, index) {
                        if (index == value.length) {
                          return IconButton.filledTonal(
                            onPressed: () {
                              _addImages().then((value) {
                                if (value.isNotEmpty) {
                                  showToast('${value.length}个图片已存在');
                                }
                                print('添加成功');
                              });
                            },
                            icon: const Icon(Icons.add),
                          );
                        } else {
                          return ChangeNotifierProvider.value(
                            value: value[index],
                            builder: (context, child) {
                              return ContextMenuWidget(
                                child: dragItemWidget(
                                  context,
                                  file: value[index].file,
                                  child: InkWell(
                                    child: Container(
                                      foregroundDecoration: RotatedCornerDecoration.withColor(
                                        color: Theme.of(context).primaryColor.withAlpha(180),
                                        badgeSize: Size.square(20.h),
                                        textSpan: TextSpan(
                                          text: value[index].mime.replaceFirst('image/', ''),
                                        ),
                                      ),
                                      child: Selector<ImageItem, Tuple2<String, File>>(
                                        builder: (context, value, child) => value.item1.isEmpty
                                            ? Image.file(value.item2)
                                            : Tooltip(
                                                message: value.item1,
                                                child: Image.file(value.item2),
                                              ),
                                        selector: (p0, p1) => Tuple2(p1.content, p1.file),
                                      ),
                                    ),
                                    onTap: () {
                                      print('tap');
                                      Navigator.pushNamed(
                                        context,
                                        ImageDetailRoute.name,
                                        arguments: ImageDetailRouteArg(
                                          imageId: value[index].iid,
                                          groupId: value[index].gid,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                menuProvider: (request) {
                                  return Menu(children: [
                                    if (PlatformUtils.isNotMobile)
                                      MenuAction(
                                        title: '复制',
                                        callback: () async {
                                          final item = DataWriterItem();
                                          getImgFormats(value[index].file).forEach(item.add);
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
                                      title: '转换格式',
                                      callback: () {
                                        Navigator.pushNamed(
                                          context,
                                          ConverterRoute.name,
                                          arguments: ConverterRouteArg(
                                            internal: true,
                                            sourceFile: value[index].file,
                                            guuid: value[index].groupUuid,
                                            hash: value[index].hash,
                                          ),
                                        );
                                      },
                                    ),
                                    MenuAction(
                                      title: '设置内容',
                                      callback: () {
                                        final controller = TextEditingController(text: value[index].content);
                                        NDialog(
                                          title: const Text('设置内容'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                autofocus: true,
                                                controller: controller,
                                                decoration: const InputDecoration(
                                                  labelText: '内容',
                                                  hintText: '图片中的文字',
                                                ),
                                                onEditingComplete: () {
                                                  final str = controller.text;
                                                  Utils.logger.i(str);
                                                  value[index].content = str;
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final str = controller.text;
                                                  Utils.logger.i(str);
                                                  value[index].content = str;
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('确定'),
                                              ),
                                            ],
                                          ),
                                        ).show(context).whenComplete(() {
                                          controller.dispose();
                                        });
                                      },
                                    ),
                                    MenuAction(
                                      title: '删除',
                                      callback: () {
                                        NAlertDialog(
                                          dialogStyle: DialogStyle(titleDivider: true),
                                          title: const Text("确定删除"),
                                          actions: <Widget>[
                                            TextButton(
                                                child: const Text("确定"),
                                                onPressed: () {
                                                  final progressDialog = ProgressDialog(context,
                                                      title: const Text('删除图片'),
                                                      message: const Text(
                                                        '正在删除',
                                                      ))
                                                    ..show();
                                                  Config.meme.groups[_tabController!.index].removeImage(value[index]).then((value) {
                                                    Navigator.pop(context);
                                                  }).whenComplete(() {
                                                    progressDialog.dismiss();
                                                  });
                                                }),
                                            TextButton(child: const Text("取消"), onPressed: () => Navigator.pop(context)),
                                          ],
                                        ).show(context);
                                      },
                                    ),
                                  ]);
                                },
                              );
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

  Future<List<ImageItem>> _addImages() {
    final completer = Completer<List<ImageItem>>();
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
        Config.meme.groups[_tabController!.index].addImages(value.map((e) => File(e.path)).toList()).then((value) {
          completer.complete(value);
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
                decoration: const InputDecoration(labelText: '组名'),
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

  Future<void> _registerPasteHotKey() async {
    _hotKey = await HotKey.create(
      definition: HotKeyDefinition(
        key: PhysicalKeyboardKey.keyV,
        control: true,
      ),
      onPressed: () {
        print('hot key pressed');
      },
    );
  }
}
