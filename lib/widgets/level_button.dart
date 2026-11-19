import 'package:flutter/material.dart';

class LevelButton extends StatelessWidget {
  final double left;
  final double top;

  final String backgroundImage;
  final String? numberImage;

  final VoidCallback onTap;

  const LevelButton({
    super.key,
    required this.left,
    required this.top,
    required this.backgroundImage,
    required this.numberImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              backgroundImage,
              width: 100,
            ),

            if (numberImage != null)
              Transform.translate(
                offset: const Offset(0, -25),
                child: Image.asset(
                  numberImage!,
                  width: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}