import 'package:flutter/material.dart';
import 'package:handle_hero/models/models.dart';

class ConnectionLinePainter extends CustomPainter {
  const ConnectionLinePainter({
    required this.completed,
    required this.letterOrder,
    required this.imageOrder,
    required this.rowHeight,
  });

  final Set<String> completed;
  final List<String> letterOrder;
  final List<LetterOption> imageOrder;
  final double rowHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = const Color(0xFF382630)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.square;
    final line = Paint()
      ..color = const Color(0xFFFFD166)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    final letterRows = <String, int>{
      for (var index = 0; index < letterOrder.length; index++)
        letterOrder[index]: index,
    };
    final imageRows = <String, int>{
      for (var index = 0; index < imageOrder.length; index++)
        imageOrder[index].letter: index,
    };

    for (final letter in completed) {
      final letterRow = letterRows[letter];
      final imageRow = imageRows[letter];
      if (letterRow == null || imageRow == null) continue;

      final start = Offset(
        size.width * 0.25,
        rowHeight * (letterRow + 0.5),
      );
      final end = Offset(
        size.width * 0.75,
        rowHeight * (imageRow + 0.5),
      );
      canvas.drawLine(start, end, outline);
      canvas.drawLine(start, end, line);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionLinePainter oldDelegate) =>
      oldDelegate.completed != completed ||
      oldDelegate.letterOrder != letterOrder ||
      oldDelegate.imageOrder != imageOrder ||
      oldDelegate.rowHeight != rowHeight;
}
