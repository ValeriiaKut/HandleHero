import 'package:flutter/material.dart';
import 'package:handle_hero/models/models.dart';

class LinePainter extends CustomPainter {
  const LinePainter({
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
    final paint = Paint()
      ..color = const Color(0xFF3CBF66)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

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

      canvas.drawLine(
        Offset(size.width * 0.25, rowHeight * (letterRow + 0.5)),
        Offset(size.width * 0.75, rowHeight * (imageRow + 0.5)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) =>
      oldDelegate.completed != completed ||
      oldDelegate.letterOrder != letterOrder ||
      oldDelegate.imageOrder != imageOrder ||
      oldDelegate.rowHeight != rowHeight;
}
