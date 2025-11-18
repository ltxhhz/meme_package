import 'package:flutter/material.dart';
import 'package:meme_package/components/tags_item.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/entities/tag.dart';
import 'package:meme_package/notifiers/tag.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:super_context_menu/super_context_menu.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TagNotifier(),
      child: const TagsPageContent(),
    );
  }
}

class TagsPageContent extends StatefulWidget {
  const TagsPageContent({super.key});

  @override
  State<TagsPageContent> createState() => _TagsPageContentState();
}

class _TagsPageContentState extends State<TagsPageContent> {
  final _tagTextController = TextEditingController();
  final _filterTextController = TextEditingController();

  @override
  void dispose() {
    _tagTextController.dispose();
    _filterTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagNotifier = Provider.of<TagNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('标签管理'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加标签的输入框
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagTextController,
                    decoration: const InputDecoration(
                      labelText: '新标签名称',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      _addTag(context, tagNotifier);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addTag(context, tagNotifier),
                  child: const Text('添加'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 过滤标签的输入框
            TextField(
              controller: _filterTextController,
              decoration: const InputDecoration(
                labelText: '过滤标签',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                tagNotifier.setFilter(value);
              },
            ),
            const SizedBox(height: 16),

            // 标签展示区域
            const Text(
              '标签列表:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 使用 Wrap 组件实现 inline 元素展示
            Expanded(
              child: Consumer<TagNotifier>(
                builder: (context, notifier, child) {
                  if (notifier.tags.isEmpty) {
                    return const Center(
                      child: Text(
                        '暂无标签',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: notifier.tags.map((tag) => _buildTagItem(context, tag)).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagItem(BuildContext context, TagEntity tag) {
    return tagItem(
      context,
      tag,
      menuItems: [
        MenuAction(
          title: '编辑',
          callback: () => _editTag(context, tag),
        ),
        MenuAction(
          title: '删除',
          callback: () => _deleteTag(context, tag),
        ),
      ],
    );
  }

  void _addTag(BuildContext context, TagNotifier tagNotifier) {
    final tagName = _tagTextController.text.trim();
    if (tagName.isNotEmpty) {
      tagNotifier.addTag(tagName).then((_) {
        _tagTextController.clear();
        showToast('标签添加成功');
      }).catchError((error) {
        showToast('标签添加失败: $error');
      });
    }
  }

  Future<void> _editTag(BuildContext context, TagEntity tag) async {
    final controller = TextEditingController(text: tag.name);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑标签'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: '标签名称'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入标签名称';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (result != null && context.mounted) {
      final tagNotifier = Provider.of<TagNotifier>(context, listen: false);
      tagNotifier.updateTag(tag.tid!, result).then((_) {
        showToast('标签更新成功');
      }).catchError((error) {
        showToast('标签更新失败: $error');
      });
    }
  }

  Future<void> _deleteTag(BuildContext context, TagEntity tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除标签 "${tag.name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final tagNotifier = context.read<TagNotifier>();
      tagNotifier.deleteTag(tag).then((_) {
        showToast('标签删除成功');
      }).catchError((error) {
        showToast('标签删除失败: $error');
      });
    }
  }
}
