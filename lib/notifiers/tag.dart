import 'package:flutter/material.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/entities/tag.dart';

class TagNotifier extends ChangeNotifier {
  List<TagEntity> _allTags = [];
  List<TagEntity> _filteredTags = [];
  String _filterText = '';

  List<TagEntity> get tags => _filteredTags;
  String get filterText => _filterText;

  TagNotifier() {
    loadTags();
  }

  Future<void> loadTags() async {
    _allTags = await Config.db.tagDao.getAllTags();
    _applyFilter();
    notifyListeners();
  }

  void setFilter(String filter) {
    _filterText = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_filterText.isEmpty) {
      _filteredTags = List.from(_allTags);
    } else {
      _filteredTags = _allTags.where((tag) => tag.name.toLowerCase().contains(_filterText.toLowerCase())).toList();
    }
  }

  Future<void> addTag(String name) async {
    if (name.trim().isNotEmpty) {
      final tag = TagEntity(name: name.trim());
      await Config.db.tagDao.addTag(tag);
      await loadTags();
    }
  }

  Future<void> updateTag(int tid, String newName) async {
    if (newName.trim().isNotEmpty) {
      // 先找到原来的标签
      final originalTag = _allTags.firstWhere((tag) => tag.tid == tid);
      final updatedTag = originalTag.copyWith(name: newName.trim());
      await Config.db.tagDao.updateTag(updatedTag);
      await loadTags();
    }
  }

  Future<void> deleteTag(TagEntity tag) async {
    await Config.db.tagDao.removeTag(tag);
    await loadTags();
  }
}
