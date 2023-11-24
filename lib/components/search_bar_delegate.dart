import 'package:flutter/material.dart';
import 'package:meme_package/notifiers/search_bar.dart';
import 'package:provider/provider.dart';

class SearchBarDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      ChangeNotifierProvider(
        create: (context) => SearchBarCN(),
        builder: (context, child) {
          return ElevatedButton.icon(
            onPressed: () {
              Provider.of<SearchBarCN>(context, listen: false).searchTag = !Provider.of<SearchBarCN>(context, listen: false).searchTag;
            },
            icon: const Icon(Icons.transform),
            label: Selector<SearchBarCN, bool>(
              builder: (context, value, child) => Text('搜索${value ? '标签' : '内容'}'),
              selector: (p0, p1) => p1.searchTag,
            ),
          );
        },
      ),
      IconButton(
        onPressed: () {},
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
    return const Center(
      child: Text('results'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Suggestions'),
    );
  }
}
