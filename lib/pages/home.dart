import 'package:flutter/material.dart';
import 'package:meme_package/components/tab_page.dart';
import 'package:meme_package/pages/converter.dart';
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
            const UserAccountsDrawerHeader(accountName: Text('accountName'), accountEmail: Text('accountEmail')),
            ListTile(
              title: Text('data'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConverterPage(),
                  ),
                );
              },
            )
          ],
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8),
        child: Column(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print(Formats.gif);
        },
      ),
    );
  }
}
