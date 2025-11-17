import 'dart:math';

import 'package:flutter/material.dart';

/// 一个用于绘制透明背景格子的CustomPainter
class LucencyPainter extends CustomPainter {
  final double squareSize;
  LucencyPainter({
    this.squareSize = 10,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.grey[400]!;

    for (double i = 0; i < size.width; i += squareSize) {
      for (double j = 0; j < size.height; j += squareSize) {
        if ((i / squareSize).floor() % 2 == (j / squareSize).floor() % 2) {
          canvas.drawRect(
            Rect.fromPoints(
              Offset(i, j),
              Offset(min(i + squareSize, size.width), min(j + squareSize, size.height)),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
