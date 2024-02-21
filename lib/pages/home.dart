import 'package:flutter/material.dart';
import 'package:meme_package/components/search_bar_delegate.dart';
import 'package:meme_package/components/tab_page.dart';
import 'package:meme_package/router/routes/converter.dart';
import 'package:meme_package/router/routes/setting.dart';
import 'package:meme_package/router/routes/test.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

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
                  launchUrl(Config.supportDir.uri).then((value) {
                    print('launch 成功');
                  });
                },
              )
            ],
            icon: const Icon(Icons.more_horiz),
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Column(
              children: [
                const UserAccountsDrawerHeader(accountName: Text('accountName'), accountEmail: Text('accountEmail')),
                ListTile(
                  title: const Text('类型转换'),
                  onTap: () {
                    Navigator.pushNamed(context, ConverterRoute.name);
                  },
                ),
                ListTile(
                  title: const Text('test'),
                  onTap: () {
                    Navigator.pushNamed(context, TestRoute.name);
                  },
                )
              ],
            ),
            ListTile(
              title: const Text('设置'),
              onTap: () {
                Navigator.pushNamed(context, SettingRoute.name);
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: '搜索', hintText: '点击搜索'),
              readOnly: true,
              onTap: () {
                showSearch(context: context, delegate: SearchBarDelegate());
              },
            ),
            const Expanded(
              child: TabPage(),
            ),
          ],
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
