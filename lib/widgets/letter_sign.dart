import 'package:flutter/material.dart';
import 'package:handle_hero/models/models.dart';

/// Shows the ASL illustration for a letter.
class LetterSign extends StatelessWidget {
  const LetterSign({super.key, required this.option, this.size = 150});

  final LetterOption option;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      option.image,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
