import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meme_package/config.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('test'),
      ),
      body: SingleChildScrollView(
        child: Text(const JsonEncoder.withIndent('  ').convert(Config.meme)),
      ),
    );
  }
}
