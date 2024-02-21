import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:meme_package/config.dart';
import 'package:ndialog/ndialog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../notifiers/setting.dart';
import '../utils.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ChangeNotifierProvider(
        create: (context) => Setting(),
        builder: (context, child) {
          return SettingsList(
            sections: [
              SettingsSection(
                title: const Text('通用'),
                tiles: [
                  SettingsTile(
                    leading: const Icon(Icons.folder_open),
                    title: const Text('表情包保存位置'),
                    value: Selector<Setting, String>(
                      builder: (context, value, child) => Text(value),
                      selector: (p0, p1) => p1.dataPath,
                    ),
                    onPressed: (_) => _showModifyDataPathDialog(context),
                  )
                ],
              )
            ],
            platform: DevicePlatform.android,
          );
        },
      ),
    );
  }

  void _showModifyDataPathDialog(BuildContext context) {
    final controller = TextEditingController();
    final settingNotifier = context.read<Setting>();
    controller.addListener(() {
      settingNotifier.dataPathNew = controller.text;
    });
    controller.text = settingNotifier.dataPath;
    Utils.logger.i(controller.text);
    NDialog(
      dialogStyle: DialogStyle(titleDivider: true),
      title: const Text('修改保存位置'),
      content: ChangeNotifierProvider.value(
        value: settingNotifier,
        builder: (context, child) => SizedBox(
          width: 500.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Selector<Setting, String>(
                      builder: (context, value, child) => TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: '请输入保存位置',
                          label: const Text('保存位置'),
                          prefix: value.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: '打开路径',
                                  onPressed: () {
                                    final dir = Directory(controller.text);
                                    if (dir.statSync().type == FileSystemEntityType.notFound) {
                                      showToast(
                                        '当前路径不存在',
                                        position: const ToastPosition(
                                          align: Alignment.bottomCenter,
                                        ),
                                      );
                                    } else if (dir.statSync().type == FileSystemEntityType.directory) {
                                      launchUrlString(controller.text);
                                    } else {
                                      showToast(
                                        '当前路径不是个文件夹',
                                        position: const ToastPosition(
                                          align: Alignment.bottomCenter,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.open_in_browser),
                                ),
                          suffix: value.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: '清空',
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    controller.clear();
                                  },
                                ),
                        ),
                      ),
                      selector: (p0, p1) => p1.dataPathNew,
                    ),
                  ),
                  IconButton(
                    tooltip: '选择路径',
                    onPressed: () {
                      getDirectoryPath().then((value) {
                        if (value != null) {
                          controller.text = value;
                          Utils.logger.i('dataPath: $value');
                        }
                      });
                    },
                    icon: const Icon(Icons.folder),
                    // label: Text('选择'),
                  )
                ],
              ),
              const Text('修改后将会立即将原文件夹的内容移动到新路径，不存在将会创建。'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('确定'),
          onPressed: () {
            // Config.dataPath = Directory(controller.text);
            // Config.init();
            Utils.logger.i('dataPath: ${controller.text}');
            if (controller.text != Config.dataPath.path) {
              final dir = Directory(controller.text);
              final stat = dir.statSync();
              if (stat.type == FileSystemEntityType.directory || stat.type == FileSystemEntityType.notFound) {
                if (dir.existsSync() && dir.listSync().isNotEmpty) {
                  showToast(
                    '当前文件夹非空',
                    position: const ToastPosition(
                      align: Alignment.bottomCenter,
                    ),
                  );
                  return;
                }
                final progress = ProgressDialog(context, title: const Text('正在移动'), message: null);
                progress.show();
                Utils.moveFolder(Config.dataPath, dir).then((value) {
                  Config.dataPath.deleteSync(recursive: true);
                  Config.dataPath = dir;
                  Config.meme.updateItemsSrc();
                  progress.dismiss();
                  showToast(
                    '保存位置修改成功',
                    position: const ToastPosition(
                      align: Alignment.bottomCenter,
                    ),
                  );
                  settingNotifier.updateDataPath();
                  Navigator.pop(context);
                }).catchError((err) {
                  progress.dismiss();
                  NAlertDialog(
                    title: const Text('保存位置修改失败'),
                    content: Text(err.toString()),
                    actions: [
                      TextButton(
                        child: const Text('确定'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ).show(context);
                });
              } else {
                showToast(
                  '当前路径不是个文件夹',
                  position: const ToastPosition(
                    align: Alignment.bottomCenter,
                  ),
                );
              }
              showToast(
                '保存位置修改成功',
                position: const ToastPosition(
                  align: Alignment.bottomCenter,
                ),
              );
            }
          },
        ),
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ).show(context);
  }
}
