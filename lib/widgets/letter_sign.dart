import 'package:flutter/material.dart';
import 'package:handle_hero/models/models.dart';

/// Shows an available ASL illustration, or a clear letter card until its
/// illustration is added to assets.
class LetterSign extends StatelessWidget {
  const LetterSign({super.key, required this.option, this.size = 150});

  final LetterOption option;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = option.image;
    if (image != null) {
      return Image.asset(image, width: size, height: size, fit: BoxFit.contain);
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF382630),
        border: Border.all(color: const Color(0xFF817B6B), width: 5),
      ),
      child: Text(
        option.letter,
        style: TextStyle(
          color: const Color(0xFFFFD55A),
          fontSize: size * .55,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
