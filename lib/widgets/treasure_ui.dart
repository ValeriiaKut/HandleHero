import 'package:flutter/material.dart';

/// Reusable pixel-art frame for dialogs and content windows.
class TreasureWindow extends StatelessWidget {
  const TreasureWindow({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _TreasureFramePainter(),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              TreasureBanner(title: title!),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class TreasureBanner extends StatelessWidget {
  const TreasureBanner({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _PixelCutClipper(cut: 9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF9A5737),
          border: Border.all(color: const Color(0xFF3A2028), width: 4),
        ),
        child: Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFFD55A),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            shadows: [Shadow(color: Color(0xFF3A2028), offset: Offset(1, 2))],
          ),
        ),
      ),
    );
  }
}

enum TreasureButtonTone { green, red, wood }

class TreasureButton extends StatelessWidget {
  const TreasureButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = TreasureButtonTone.green,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final TreasureButtonTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      TreasureButtonTone.green => const Color(0xFF547541),
      TreasureButtonTone.red => const Color(0xFF8D3D35),
      TreasureButtonTone.wood => const Color(0xFF9A5737),
    };
    return ClipPath(
      clipper: const _PixelCutClipper(cut: 7),
      child: Material(
        color: onPressed == null ? const Color(0xFF50434A) : color,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF251A24), width: 4),
              boxShadow: const [
                BoxShadow(color: Color(0xFFB9AA83), offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: const Color(0xFFFFE8B2), size: 18),
                  const SizedBox(width: 7),
                ],
                Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE8B2),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                    shadows: [
                      Shadow(color: Color(0xFF251A24), offset: Offset(1, 2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TreasureFramePainter extends CustomPainter {
  const _TreasureFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    Path polygon(Rect rect, double cut) => Path()
      ..moveTo(rect.left + cut, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right - cut, rect.top + cut)
      ..lineTo(rect.right, rect.top + cut)
      ..lineTo(rect.right, rect.bottom - cut)
      ..lineTo(rect.right - cut, rect.bottom - cut)
      ..lineTo(rect.right - cut, rect.bottom)
      ..lineTo(rect.left + cut, rect.bottom)
      ..lineTo(rect.left + cut, rect.bottom - cut)
      ..lineTo(rect.left, rect.bottom - cut)
      ..lineTo(rect.left, rect.top + cut)
      ..lineTo(rect.left + cut, rect.top + cut)
      ..close();

    canvas.drawPath(
      polygon(Offset.zero & size, 12),
      Paint()..color = const Color(0xFF28202A),
    );
    canvas.drawPath(
      polygon(Rect.fromLTWH(5, 5, size.width - 10, size.height - 10), 9),
      Paint()..color = const Color(0xFF817B6B),
    );
    canvas.drawPath(
      polygon(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), 7),
      Paint()..color = const Color(0xFF382630),
    );
    final rivet = Paint()..color = const Color(0xFFC0B18A);
    for (final point in <Offset>[
      const Offset(5, 15),
      Offset(size.width - 8, 15),
      Offset(5, size.height - 15),
      Offset(size.width - 8, size.height - 15),
    ]) {
      canvas.drawRect(Rect.fromLTWH(point.dx, point.dy, 3, 3), rivet);
    }
  }

  @override
  bool shouldRepaint(covariant _TreasureFramePainter oldDelegate) => false;
}

class _PixelCutClipper extends CustomClipper<Path> {
  const _PixelCutClipper({required this.cut});

  final double cut;

  @override
  Path getClip(Size size) => Path()
    ..moveTo(cut, 0)
    ..lineTo(size.width - cut, 0)
    ..lineTo(size.width - cut, cut)
    ..lineTo(size.width, cut)
    ..lineTo(size.width, size.height - cut)
    ..lineTo(size.width - cut, size.height - cut)
    ..lineTo(size.width - cut, size.height)
    ..lineTo(cut, size.height)
    ..lineTo(cut, size.height - cut)
    ..lineTo(0, size.height - cut)
    ..lineTo(0, cut)
    ..lineTo(cut, cut)
    ..close();

  @override
  bool shouldReclip(covariant _PixelCutClipper oldClipper) =>
      oldClipper.cut != cut;
}
