import 'package:flutter/material.dart';

class SearchBarCN extends ChangeNotifier {
  bool _searchTag = false;
  bool get searchTag => _searchTag;

  set searchTag(bool e) {
    _searchTag = e;
    notifyListeners();
  }
}
