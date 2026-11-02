import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Set<String> completed;
  final List<String> letters;

  LinePainter(this.completed, this.letters);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final letterX = size.width * 0.25;
    final imageX = size.width * 0.75;

    final spacing = size.height / (letters.length + 1);

    for (int i = 0; i < letters.length; i++) {
      final key = letters[i];

      if (completed.contains(key)) {
        final y = spacing * (i + 1);

        canvas.drawLine(
          Offset(letterX, y),
          Offset(imageX, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) => true;
}