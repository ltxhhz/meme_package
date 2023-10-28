import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:meme_package/components/tab_page.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('home'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('配置目录'),
                onTap: () {
                  launchUrl(Utils.supportDir.uri).then((value) {
                    print('launch 成功');
                  });
                },
              )
            ],
            icon: const Icon(Icons.more_horiz),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ContextMenuOverlay(
          child: const Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: '搜索'),
              ),
              Expanded(
                child: TabPage(),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print(Formats.gif);
        },
      ),
    );
  }
}
