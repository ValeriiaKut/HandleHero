import 'package:flutter/material.dart';

/// Reusable pixel-art frame for dialogs and content windows.
class TreasureWindow extends StatelessWidget {
  const TreasureWindow({
    super.key,
    required this.child,
    this.title,
    this.showFrame = true,
    this.backgroundColor = const Color(0xFF382630),
    this.titleBackgroundColor = const Color(0xFF9A5737),
  });

  final Widget child;
  final String? title;
  final bool showFrame;
  final Color backgroundColor;
  final Color titleBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: showFrame ? _TreasureFramePainter(backgroundColor) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final inset = (constraints.maxWidth * .035).clamp(10.0, 18.0);
          return Padding(
            padding: EdgeInsets.all(inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  TreasureBanner(
                    title: title!,
                    backgroundColor: titleBackgroundColor,
                  ),
                  SizedBox(height: (inset * .75).clamp(8.0, 14.0)),
                ],
                child,
              ],
            ),
          );
        },
      ),
    );
  }
}

class TreasureBanner extends StatelessWidget {
  const TreasureBanner({
    super.key,
    required this.title,
    this.backgroundColor = const Color(0xFF9A5737),
  });

  final String title;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _PixelCutClipper(cut: 9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: const Color(0xFF3A2028), width: 4),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
      ),
    );
  }
}

class TreasureLabel extends StatelessWidget {
  const TreasureLabel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _PixelCutClipper(cut: 7),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFF8D3D35),
          border: Border.all(color: const Color(0xFF251A24), width: 4),
          boxShadow: const [
            BoxShadow(color: Color(0xFFB9AA83), offset: Offset(0, -2)),
          ],
        ),
        child: child,
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
    this.outlinedLabel = false,
    this.labelFontSize = 10,
    this.labelColor = const Color(0xFFFFE8B2),
    this.labelShadow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final TreasureButtonTone tone;
  final IconData? icon;
  final bool outlinedLabel;
  final double labelFontSize;
  final Color labelColor;
  final bool labelShadow;

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
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _ButtonLabel(
                      text: label.toUpperCase(),
                      outlined: outlinedLabel,
                      fontSize: labelFontSize,
                      color: labelColor,
                      showShadow: labelShadow,
                      ),
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

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.text,
    required this.outlined,
    required this.fontSize,
    required this.color,
    required this.showShadow,
  });

  final String text;
  final bool outlined;
  final double fontSize;
  final Color color;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: .5,
      shadows: showShadow
          ? const [Shadow(color: Color(0xFF251A24), offset: Offset(1, 2))]
          : const [],
    );
    final fill = Text(text, textAlign: TextAlign.center, style: baseStyle);
    if (!outlined) return fill;
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            color: null,
            shadows: const [],
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black,
          ),
        ),
        fill,
      ],
    );
  }
}

class _TreasureFramePainter extends CustomPainter {
  const _TreasureFramePainter(this.backgroundColor);

  final Color backgroundColor;

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
      Paint()..color = backgroundColor,
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
  bool shouldRepaint(covariant _TreasureFramePainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
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
