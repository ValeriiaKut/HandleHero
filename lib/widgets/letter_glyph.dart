import 'package:flutter/material.dart';

class LetterGlyph extends StatelessWidget {
  const LetterGlyph({super.key, required this.letter, this.size = 44});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalizedLetter = letter.toUpperCase();
    return Image.asset(
      'assets/images/$normalizedLetter.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: normalizedLetter,
      errorBuilder: (context, error, stackTrace) => Text(
        normalizedLetter,
        style: TextStyle(fontSize: size * .65, fontWeight: FontWeight.bold),
      ),
    );
  }
}
