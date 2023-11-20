import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meme_package/components/lucency.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/notifiers/image.dart';
import 'package:meme_package/notifiers/meme.dart';
import 'package:meme_package/router/routes/image_detail.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageDetailPage extends StatelessWidget {
  const ImageDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as ImageDetailRouteArg;

    return Scaffold(
      appBar: AppBar(
        title: const Text('图片详情'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ChangeNotifierProvider.value(
          value: Config.meme,
          builder: (context, child) {
            return Selector<Meme, Item>(
              builder: (context, value, child) => Column(
                children: [
                  SizedBox(
                    width: 100.r,
                    height: 100.r,
                    child: CustomPaint(
                      painter: LucencyPainter(),
                      child: Image.file(
                        value.file,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.r),
                    child: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(children: [
                          _tableHead(title: 'id'),
                          TableRowInkWell(
                            child: _sizedText(value.iid.toString()),
                            onTap: () {
                              showToast(value.iid.toString());
                            },
                          ),
                        ]),
                        TableRow(children: [
                          _tableHead(title: 'gid'),
                          TableRowInkWell(
                            child: _sizedText(value.gid.toString()),
                          ),
                        ]),
                        TableRow(children: [
                          _tableHead(title: 'mime'),
                          TableRowInkWell(
                            child: _sizedText(value.mime),
                          ),
                        ]),
                        TableRow(children: [
                          _tableHead(title: 'hash'),
                          TableRowInkWell(
                            child: _sizedText(value.hash),
                          ),
                        ]),
                        TableRow(children: [
                          _tableHead(title: 'path'),
                          TableRowInkWell(
                            child: _sizedText(value.file.path),
                            onTap: () {
                              launchUrl(value.file.parent.uri);
                            },
                          ),
                        ]),
                        TableRow(children: [
                          _tableHead(title: '添加日期'),
                          TableRowInkWell(
                            child: _sizedText(DateFormat('yyyy-MM-dd HH:mm:ss').format(value.time)),
                          ),
                        ]),
                        TableRow(children: [
                          _tableHead(title: 'groupUuid'),
                          TableRowInkWell(
                            child: _sizedText(value.groupUuid),
                          ),
                        ]),
                      ],
                    ),
                  )
                ],
              ),
              selector: (p0, p1) => p1.groups.firstWhere((g) => g.gid == arg.groupId).getImageById(arg.imageId),
            );
          },
        ),
      ),
    );
  }

  TableCell _tableHead({required String title}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _sizedText(title),
      ),
    );
  }

  Text _sizedText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 10.sp),
    );
  }
}
