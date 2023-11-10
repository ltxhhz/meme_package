import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meme_package/notifiers/converter_task.dart';
import 'package:provider/provider.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../router/routes/converter.dart';

class ConverterTable extends StatelessWidget {
  const ConverterTable({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as ConverterRouteArg?;

    return Selector<ConverterTasks, List<ConverterTask>>(
      builder: (context, value, child) {
        return Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth()
          },
          children: [
            const TableRow(children: [
              TableCell(
                child: Text(
                  '#',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  '源文件',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TableCell(
                child: Text(
                  '目标文件',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            ..._buildTable(value, arg: arg),
          ],
        );
      },
      selector: (p0, p1) => p1.tasks,
      shouldRebuild: (previous, next) => true,
    );
  }

  List<TableRow> _buildTable(List<ConverterTask> tasks, {ConverterRouteArg? arg}) {
    List<TableRow> list = [];
    for (var i = 0; i < tasks.length; i++) {
      final e = tasks[i];
      final ii = i;
      list.add(TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.only(right: 5.sp),
              child: Text(i.toString()),
            ),
          ),
          TableCell(
            child: ContextMenuWidget(
              child: InkWell(
                onTap: () {
                  // Process.run('explorer', [
                  //   '/select,',
                  //   e.source.path,
                  // ]);
                  launchUrl(e.source.parent.uri);
                },
                child: Text(e.source.path),
              ),
              menuProvider: (request) => Menu(children: [
                MenuAction(
                  title: '复制路径',
                  callback: () {},
                ),
                MenuAction(
                  title: '复制图片',
                  callback: () {},
                ),
                MenuAction(
                  title: '另存为',
                  callback: () {},
                ),
                if (arg?.internal == true)
                  MenuAction(
                    title: '替换原图',
                    callback: () {},
                  )
              ]),
            ),
          ),
          TableCell(
            child: Selector<ConverterTasks, Tuple2<File, double>>(
              builder: (context, value, child) {
                if (value.item2 == 1) {
                  return InkWell(
                    onTap: () {
                      launchUrl(value.item1.parent.uri);
                    },
                    child: Text(value.item1.path),
                  );
                } else if (value.item2 == -1) {
                  return const Text('error');
                } else {
                  // return Text('${value.item2 * 100}%');
                  return Center(
                    child: LoadingAnimationWidget.prograssiveDots(color: Theme.of(context).primaryColor, size: 10.sp),
                  );
                }
              },
              selector: (p0, p1) => Tuple2(p1.tasks[ii].target, p1.tasks[ii].rate),
            ),
          ),
        ],
      ));
    }
    return list;
  }
}
