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
        color: const Color(0xFFFFF1C7),
        border: Border.all(color: const Color(0xFF6B3E26), width: 5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        option.letter,
        style: TextStyle(
          color: const Color(0xFF6B3E26),
          fontSize: size * .55,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
