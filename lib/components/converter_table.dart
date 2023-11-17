import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/notifiers/converter_task.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../router/routes/converter.dart';

late ConverterRouteArg? _arg;

class ConverterTable extends StatelessWidget {
  const ConverterTable({super.key});

  @override
  Widget build(BuildContext context) {
    _arg = ModalRoute.of(context)!.settings.arguments as ConverterRouteArg?;

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
            ..._buildTable(value, arg: _arg),
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
            child: _buildMenu(e, isSource: true),
          ),
          TableCell(
            child: Selector<ConverterTasks, Tuple2<ConverterTask, double>>(
              builder: (context, value, child) {
                if (value.item2 == 1) {
                  return _buildMenu(value.item1);
                } else if (value.item2 == -1) {
                  return const Text('error');
                } else {
                  // return Text('${value.item2 * 100}%');
                  return Center(
                    child: LoadingAnimationWidget.prograssiveDots(color: Theme.of(context).primaryColor, size: 10.sp),
                  );
                }
              },
              selector: (p0, p1) => Tuple2(p1.tasks[ii], p1.tasks[ii].rate),
            ),
          ),
        ],
      ));
    }
    return list;
  }

  ContextMenuWidget _buildMenu(
    ConverterTask converterTask, {
    bool isSource = false,
    Widget? child,
  }) {
    return ContextMenuWidget(
      child: InkWell(
        onTap: () {
          // Process.run('explorer', [
          //   '/select,',
          //   e.source.path,
          // ]);
          launchUrl(isSource ? converterTask.source.parent.uri : converterTask.target.parent.uri);
        },
        child: Text(isSource ? converterTask.source.path : converterTask.target.path),
      ),
      menuProvider: (request) => Menu(
        children: [
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
          if (_arg?.internal == true && !isSource)
            MenuAction(
              title: '替换原图',
              callback: () {
                Config.meme.updateItem(guuid: _arg!.guuid!, hash: _arg!.hash!, file: converterTask.target).then((e) {
                  showToast('success');
                });
              },
            )
        ],
      ),
    );
  }
}
