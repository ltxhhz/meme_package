import 'package:flutter/material.dart';
import 'package:meme_package/config.dart';

class Setting extends ChangeNotifier {
  String _dataPath = Config.dataPath.path;
  String get dataPath => _dataPath;

  set dataPath(String e) {
    _dataPath = e;
    notifyListeners();
  }

  void updateDataPath() {
    _dataPath = _dataPathNew;
    notifyListeners();
  }

  String _dataPathNew = '';
  String get dataPathNew => _dataPathNew;

  set dataPathNew(String e) {
    _dataPathNew = e;
    notifyListeners();
  }
}
