import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meme_package/components/converter_table.dart';
import 'package:meme_package/components/drop_region.dart';
import 'package:meme_package/notifiers/converter_task.dart';
import 'package:meme_package/router/routes/converter.dart';
import 'package:provider/provider.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:tuple/tuple.dart';

import '../config.dart';
import '../utils.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final arg = ModalRoute.of(context)!.settings.arguments as ConverterRouteArg?;
    if (arg != null) {
      if (arg.sourceFile != null) {
        controller.text = arg.sourceFile!.path;
        Config.converterTasks.inputFile = arg.sourceFile;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('格式转换'),
      ),
      body: ChangeNotifierProvider.value(
        value: Config.converterTasks,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                        child: SizedBox(
                          height: 30.h,
                          child: MyDropRegionWidget(
                            makeTemp: false,
                            onReceive: (files) {
                              controller.text = files[0].path;
                              Config.converterTasks.inputFile = files[0];
                            },
                            child: TextField(
                              decoration: const InputDecoration(label: Text('源文件（可拖动文件到此）')),
                              controller: controller,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Selector<ConverterTasks, String>(
                      builder: (context, value, child) => Text(value),
                      selector: (p0, p1) => p1.inputFormat?.mimeTypes![0] ?? '',
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                        if (result != null) {
                          Config.converterTasks.inputFile = File(result.files.single.path!);
                          controller.text = result.files.single.path!;
                        }
                      },
                      child: const Text('选择文件'),
                    ),
                    Selector<ConverterTasks, bool>(
                      builder: (context, value, child) => ElevatedButton(
                        onPressed: value
                            ? () {
                                Config.converterTasks.push();
                                // Future.delayed(Duration(seconds: 3));
                                Utils.logger.i('wait');
                              }
                            : null,
                        child: const Text('转换'),
                      ),
                      selector: (p0, p1) => p1.inputFile != null && p1.inputFormat != null,
                    ),
                    const Text('为'),
                    Selector<ConverterTasks, Tuple2<bool, SimpleFileFormat>>(
                      builder: (context, value, child) {
                        if (value.item1) {
                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                            Config.converterTasks.targetFormat = Formats.gif;
                          });
                        }
                        return DropdownButton<SimpleFileFormat>(
                          // isDense: true,
                          hint: const Text('选择格式'),
                          items: [
                            DropdownMenuItem(
                              value: Formats.png,
                              enabled: !value.item1,
                              child: const Text('png'),
                            ),
                            DropdownMenuItem(
                              value: Formats.jpeg,
                              enabled: !value.item1,
                              child: const Text('jpg'),
                            ),
                            const DropdownMenuItem(
                              value: Formats.gif,
                              child: Text('gif'),
                            ),
                          ],
                          onChanged: (value) {
                            Config.converterTasks.targetFormat = value!;
                          },
                          value: value.item1 ? Formats.gif : value.item2,
                        );
                      },
                      selector: (p0, p1) => Tuple2(p1.isWebpDynamic, p1.targetFormat),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Config.converterTasks.clearTasks();
                      },
                      child: const Text('清空'),
                    )
                  ],
                ),
                const Divider(),
                const ConverterTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
