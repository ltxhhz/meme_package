import 'package:flutter/material.dart';
import 'package:meme_package/components/image_grid.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/entities/image.dart';
import 'package:meme_package/entities/tag.dart';
import 'package:meme_package/router/routes/converter.dart';
import 'package:meme_package/router/routes/image_detail.dart';
import 'package:meme_package/utils.dart';
import 'package:ndialog/ndialog.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_context_menu/super_context_menu.dart';

import '../notifiers/image.dart';

class SearchBarDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // ChangeNotifierProvider(
      //   create: (context) => SearchBarCN(),
      //   builder: (context, child) {
      //     return ElevatedButton.icon(
      //       onPressed: () {
      //         Provider.of<SearchBarCN>(context, listen: false).searchTag = !Provider.of<SearchBarCN>(context, listen: false).searchTag;
      //       },
      //       icon: const Icon(Icons.transform),
      //       label: Selector<SearchBarCN, bool>(
      //         builder: (context, value, child) => Text('搜索${value ? '标签' : '内容'}'),
      //         selector: (p0, p1) => p1.searchTag,
      //       ),
      //     );
      //   },
      // ),
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, '');
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final future = Config.db.imageDao.searchByContent(query);
    final future1 = Config.db.tagDao.searchTag(query);
    // Config.meme.
    // return Column(
    //   children: [],
    // );
    return FutureBuilder(
      future: Future.wait([
        future,
        future1
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 加载中
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // 错误提示
        } else {
          final images = snapshot.data![0] as List<ImageEntity>;
          final tags = snapshot.data![1] as List<TagEntity>;
          return Column(
            children: [
              Row(
                children: tags.map((tag) => Text(tag.name)).toList(),
              ),
              if (tags.isNotEmpty) Spacer(),
              if (images.isEmpty) Text('没有结果'),
              if (images.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imageItem = ImageItem.fromEntity(images[index]);
                    return ChangeNotifierProvider.value(
                      value: imageItem,
                      builder: (context, child) {
                        return imageGrid(
                          context,
                          imageItem,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ImageDetailRoute.name,
                              arguments: ImageDetailRouteArg(
                                imageId: imageItem.iid,
                                groupId: imageItem.gid,
                              ),
                            );
                          },
                          menuElements: [
                            MenuAction(
                              title: '复制',
                              callback: () async {
                                final item = DataWriterItem();
                                getImgFormats(imageItem.file).forEach(item.add);
                                if (SystemClipboard.instance != null) {
                                  SystemClipboard.instance!.write([
                                    item
                                  ]).then((value) {
                                    showToast('已复制');
                                  });
                                } else {
                                  showToast('当前平台不支持');
                                }
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
                                    sourceFile: imageItem.file,
                                    hash: imageItem.hash,
                                  ),
                                );
                              },
                            ),
                            MenuAction(
                              title: '设置内容',
                              callback: () {
                                final controller = TextEditingController(text: imageItem.content);
                                NDialog(
                                  title: const Text('设置内容'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        autofocus: true,
                                        controller: controller,
                                        maxLines: null,
                                        decoration: const InputDecoration(
                                          labelText: '内容',
                                          hintText: '图片中的文字',
                                        ),
                                        onEditingComplete: () {
                                          final str = controller.text;
                                          Utils.logger.i(str);
                                          imageItem.content = str;
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
                                          imageItem.content = str;
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
                                          Config.db.imageDao.removeImage(imageItem.imageEntity).then((value) {
                                            showToast(value > 0 ? '删除成功' : '删除失败');
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          }).whenComplete(() {
                                            progressDialog.dismiss();
                                          });
                                        }),
                                    TextButton(child: const Text("取消"), onPressed: () => Navigator.pop(context)),
                                  ],
                                ).show(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
            ],
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final tagsFuture = Config.db.tagDao.searchTag(query);

    return FutureBuilder(
      future: tagsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 加载中
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // 错误提示
        } else {
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].name),
                onTap: () {
                  query = snapshot.data![index].name;
                  showResults(context);
                },
              );
            },
            itemCount: snapshot.data!.length,
          );
        }
      },
    );
  }
}
